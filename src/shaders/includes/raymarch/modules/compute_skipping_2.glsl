    
bool compute_skipping_2
(
    in sampler3D occumap,
    in uniforms_occupancy u_occupancy,
    in uniforms_volume u_volume,  
    in parameters_ray ray,
    in parameters_trace trace,
    out float skip_depth
) 
{
    vec3 voxel_coords = trace.position * u_volume.inv_spacing;
    vec3 block_coords = floor(voxel_coords / u_occupancy.block_dimensions);
    vec3 block_texel = (block_coords + 0.5) / u_occupancy.occumap_dimensions;
    // gl_FragColor = vec4(voxel_coords * u_volume.inv_dimensions, 1.0);
    // gl_FragColor = vec4(block_texel, 1.0);

    // Sample the occupancy map to get occupancy data
    vec4 multi_ocupancy = step(0.5, texture(occumap, block_texel));
    float occupancy_resolution = 3.0 - multi_ocupancy.g - multi_ocupancy.b - multi_ocupancy.a;
    float block_scaling = exp2(occupancy_resolution); 
    // gl_FragColor = vec4(multi_ocupancy);
    // gl_FragColor = vec4(vec3(occupancy_resolution / 3.0), 1.0);

    // compute block0 min and max voxel coordinates
    vec3 bblock_dimensions = u_occupancy.block_dimensions * block_scaling;
    vec3 bblock_min_voxel_pos = floor(voxel_coords / bblock_dimensions) * bblock_dimensions;
    vec3 bblock_max_voxel_pos = bblock_min_voxel_pos + bblock_dimensions; // if we had coords we would need to subtract one

    // normalize and camp block voxel positions
    bblock_min_voxel_pos = bblock_min_voxel_pos * u_volume.spacing;
    bblock_max_voxel_pos = bblock_max_voxel_pos * u_volume.spacing;
    // gl_FragColor = vec4(bblock_min_voxel_pos / u_volume.size, 1.0);
    // gl_FragColor = vec4(bblock_max_voxel_pos / u_volume.size, 1.0);
      
    // intersect ray with block
    skip_depth = intersect_box_max(bblock_min_voxel_pos, bblock_max_voxel_pos, trace.position, ray.direction); 
    // gl_FragColor = vec4(vec3(skip_depth / ray.span), 1.0);

    // check if block is occupied
    return multi_ocupancy.r > 0.5;
}