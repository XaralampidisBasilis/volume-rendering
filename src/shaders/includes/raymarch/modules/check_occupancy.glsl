    
bool check_occupancy
(
    in sampler3D occumap,
    in uniforms_occupancy u_occupancy,
    in uniforms_volume u_volume,  
    in parameters_ray ray,
    in parameters_trace trace,
    out int skip_steps
) 
{
    vec3 voxel_coords = trace.position * u_volume.inv_spacing;
    vec3 block_coords = floor(voxel_coords / u_occupancy.block_dimensions);
    vec3 block_texel = (block_coords + 0.5) / u_occupancy.occumap_dimensions;
    
    // Sample the occupancy map to get occupancy data
    vec4 multi_ocupancy = step(0.5, texture(occumap, block_texel));
    float occupancy_resolution = 3.0 - multi_ocupancy.g - multi_ocupancy.b - multi_ocupancy.a;
    float block_scaling = exp2(occupancy_resolution); 

    // compute block0 min and max voxel coordinates
    vec3 bblock_dimensions = u_occupancy.block_dimensions * block_scaling;
    vec3 bblock_min_voxel_pos = floor(voxel_coords / bblock_dimensions) * bblock_dimensions;
    vec3 bblock_max_voxel_pos = bblock_min_voxel_pos + bblock_dimensions; // if we had coords we would need to subtract one

    // normalize and camp block voxel positions
    bblock_min_voxel_pos = min(bblock_min_voxel_pos * u_volume.spacing, u_volume.size);
    bblock_max_voxel_pos = min(bblock_max_voxel_pos * u_volume.spacing, u_volume.size);
      
    // intersect ray with block
    float distance = intersect_box_max(bblock_min_voxel_pos, bblock_max_voxel_pos, trace.position, ray.step); 
    skip_steps = max(int(ceil(distance)), 1); 

    // check if block is occupied
    return multi_ocupancy.r > 0.5;
}