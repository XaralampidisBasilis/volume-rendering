    
bool blockskip(
    in sampler3D occumap,
    in vec3 block_dimensions, 
    in vec3 volume_dimensions, 
    in vec3 ray_position, 
    in vec3 ray_step, 
    out float skip_steps
) {

    // check if block is occupied
    bool occupied = sample_intensity_3d(occumap, ray_position) > 0.0;

    // compute block0 min and max voxel coordinates
    vec3 block_min = floor(ray_position * block_dimensions);
    vec3 block_max = min(block_min + block_dimensions, volume_dimensions);
    
    // normalize block box coordinates
    block_min /= volume_dimensions;
    block_max /= volume_dimensions;

    // intersect ray with block
    skip_steps = intersect_box_max(block_min, block_max, ray_position, ray_step); 
    skip_steps = max(ceil(skip_steps), 0.0);

    return occupied;
}