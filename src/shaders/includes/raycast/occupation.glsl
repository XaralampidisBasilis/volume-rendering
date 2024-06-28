/**
 * Determines if a block in the volume can be skipped based on an occupancy map
 * and computes the number of steps to exit the block.
 *
 * @param occupancy_map - The occupancy map texture.
 * @param volume_position - The current position in  the volume (normalized coordinates [0, 1]).
 * @param ray_step - The step vector of the ray.
 * @param num_blocks - The dimensions of the occupancy map (number of blocks in each dimension).
 * @param block_size - The size of a block in the volume (normalized coordinates).
 * @param num_steps - The output parameter that will store the number of steps to exit the block.
 * @return - Returns true if the block is occupied and the ray should not skip it, false otherwise.
 */
bool occupation(in occupancy_uniforms u_occupancy, in sampler2D occupancy_map, in vec3 num_blocks, in vec3 block_size, in vec3 volume_uvw, in vec3 ray_step, out float exit_steps)
{
    // find the current block index in the volume
    vec3 block_index = floor(volume_uvw / block_size);

    // compute block min and max coordinates in the volume
    vec3 block_min = block_index * block_size;
    vec3 block_max = min(block_min + block_size, 1.0);

    // intersect the ray with the block and compute the distance to exit
    float distance = intersect_box_max(block_min, block_max, volume_uvw, ray_step);
    exit_steps = ceil(distance);

    // compute the block position in the occupancy map's normalized coordinates
    vec3 block_uvw = block_index / num_blocks;
    vec2 block_uv = reshape_3d_to_2d_texel(block_uvw, num_blocks);

    // sample the occupancy map at the block position
    // if the sampled value is greater than 0, the block is occupied
    bool occupied = sample_intensity_2d(occupancy_map, block_uv) > 0.0;

    return occupied;
    
}
