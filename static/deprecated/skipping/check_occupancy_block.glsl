    
bool check_occupancy_block
(
    in sampler3D occumap,
    in vec3 occumap_dimensions,
    in vec3 block_dimensions, 
    in vec3 volume_dimensions,
    in vec3 ray_position, 
    in vec3 ray_step, 
    out int skip_steps
) 
{
    vec3 voxel_coords = floor(ray_position * volume_dimensions);
    vec3 block_coords = floor(voxel_coords / block_dimensions);

    // compute block0 min and max voxel coordinates
    vec3 block_min_voxel_pos = block_coords * block_dimensions;
    vec3 block_max_voxel_pos = block_min_voxel_pos + block_dimensions; // if we had coords we would need to subtract one

    // normalize block voxel positions
    vec3 inv_vol_dim = 1.0 / volume_dimensions;
    block_min_voxel_pos *= inv_vol_dim;
    block_max_voxel_pos *= inv_vol_dim;

    // normalize block position
    block_coords = (block_coords + 0.5) / occumap_dimensions;
    
    // intersect ray with block
    float distance = intersect_box_max(block_min_voxel_pos, block_max_voxel_pos, ray_position, ray_step); 
    skip_steps = int(ceil(distance)); 
    skip_steps = max(skip_steps, 1); 

    // check if block is occupied
    bool occupied = bool(sample_intensity_3d(occumap, block_coords)); 

    return occupied;
}