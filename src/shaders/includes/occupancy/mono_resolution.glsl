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
bool mono_resolution(
    in uniforms_occupancy u_occupancy, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    in vec3 ray_step, 
    out vec2 traverse_steps,
    out float exit_steps
) {
    // calculate normalized block size
    vec3 block_size = u_occupancy.block / u_volume.dimensions;

    // find the current block index in the volume
    vec3 block_index = floor(ray_position / block_size);

    // compute the block position in the occupancy map's normalized coordinates
    vec3 block_uvw = (block_index + 0.5) / u_occupancy.size;
    vec2 block_uv = reshape_3d_to_2d_texel(block_uvw, u_occupancy.size);

    // sample the occupancy map at the block position
    // if the sampled value is greater than 0, the block is occupied
    float occupied_intensity = sample_intensity_2d(u_sampler.occupancy, block_uv);
    bool occupied = occupied_intensity > 0.0;

    // compute block voxel min and max coordinates in the volume
    vec3 voxel_min = max(block_index * block_size, 0.0);
    vec3 voxel_max = min(voxel_min + block_size, 1.0);

    // intersect ray with block and compute skip steps
    exit_steps = intersect_box_max(voxel_min, voxel_max, ray_position, ray_step); // gl_FragColor = vec4(vec3(distance/length(u_occupancy.block) * length(ray_step)), 1.0);
    exit_steps = max(floor(exit_steps), 0.0);

    // compute traverse steps
    traverse_steps = vec2(0.0, exit_steps);
    
    return occupied;
    
}
