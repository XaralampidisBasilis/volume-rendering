    
bool compute_skipping
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
    ivec3 block_coords = ivec3(voxel_coords / u_occupancy.block_dimensions);
    // gl_FragColor = vec4(voxel_coords * u_volume.inv_dimensions, 1.0);
    // gl_FragColor = vec4(block_texel, 1.0);

    // Sample the occupancy map to get occupancy data
    vec4 multi_ocupancy = step(0.5, texelFetch(occumap, block_coords, 0));
    float occupancy_resolution = 3.0 - dot(multi_ocupancy.gba, vec3(1.0));
    float block_scaling = exp2(occupancy_resolution); 
    // gl_FragColor = vec4(multi_ocupancy);
    // gl_FragColor = vec4(vec3(occupancy_resolution / 3.0), 1.0);

    // compute block0 min and max voxel coordinates
    vec3 block_size = u_occupancy.block_dimensions * u_volume.spacing * block_scaling;
    vec3 block_min_voxel_pos = floor(trace.position / block_size) * block_size;
    vec3 block_max_voxel_pos = block_min_voxel_pos + block_size; // if we had coords we would need to subtract one
    block_min_voxel_pos = min(block_min_voxel_pos, u_volume.size);
    block_max_voxel_pos = min(block_max_voxel_pos, u_volume.size);
    // gl_FragColor = vec4(block_min_voxel_pos / u_volume.size, 1.0);
    // gl_FragColor = vec4(block_max_voxel_pos / u_volume.size, 1.0);  
      
    // intersect ray with block
    float distance = intersect_box_max(block_min_voxel_pos, block_max_voxel_pos, trace.position, ray.step); 
    skip_steps = max(int(ceil(distance)), 1); 
    // gl_FragColor = vec4(vec3(skip_steps)/vec3(ray.max_steps), 1.0);

    // check if block is occupied
    return multi_ocupancy.r > 0.5;
}