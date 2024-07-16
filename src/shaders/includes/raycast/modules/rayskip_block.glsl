    
bool rayskip_block
(
    in sampler3D occumap,
    in vec3 occumap_dimensions,
    in vec3 block_dimensions, 
    in vec3 volume_dimensions,
    in vec3 ray_position, 
    in vec3 ray_step, 
    out int skip_steps
) {

    vec3 voxel_position = ray_position * volume_dimensions; // for some reason if I floor this and set divisions to 10 there a problems
    vec3 block_position = floor(voxel_position / block_dimensions);

    // compute block0 min and max voxel coordinates
    vec3 block_min_voxel_pos = block_position * block_dimensions ;
    vec3 block_max_voxel_pos = min(block_min_voxel_pos + block_dimensions, volume_dimensions); // if we had coords we would need to subtract one

    // normalize block voxel positions
    vec3 inv_vol_dim = 1.0 / volume_dimensions;
    block_min_voxel_pos *= inv_vol_dim;
    block_max_voxel_pos *= inv_vol_dim;

    // normalize block position
    block_position = (block_position + 0.5) / occumap_dimensions;
    
    // intersect ray with block
    float distance = intersect_box_max(block_min_voxel_pos, block_max_voxel_pos, ray_position, ray_step); 
    skip_steps = int(ceil(distance)); // we need ceil to go just outside of the block
    
    // check if block is occupied
    bool occupied = bool(sample_intensity_3d(occumap, block_position));

    return occupied;
}