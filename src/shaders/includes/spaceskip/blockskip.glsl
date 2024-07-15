    
bool blockskip(
    in sampler3D occumap,
    in vec3 occumap_dimensions,
    in vec3 block_dimensions, 
    in vec3 volume_dimensions,
    in vec3 ray_position, 
    in vec3 ray_step, 
    out int skip_steps
) {

    vec3 voxel_position = ray_position * volume_dimensions;
    vec3 block_position = floor(voxel_position / block_dimensions);

    // compute block0 min and max voxel coordinates
    vec3 block_voxel_min = block_position * block_dimensions;
    vec3 block_voxel_max = min(block_voxel_min + block_dimensions, volume_dimensions);
    
    // normalize block position
    block_position /= occumap_dimensions;

    // check if block is occupied
    bool occupied = bool(sample_intensity_3d(occumap, block_position));
    
    // normalize block box coordinates
    block_voxel_min /= volume_dimensions;
    block_voxel_max /= volume_dimensions;

    // intersect ray with block
    float distance = intersect_box_max(block_voxel_min, block_voxel_max, ray_position, ray_step); 
    skip_steps = int(max(ceil(distance), 1.0));
    

    return occupied;
}