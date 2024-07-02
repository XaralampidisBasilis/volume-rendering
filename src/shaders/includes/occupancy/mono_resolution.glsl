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
bool mono_resolution(in occupancy_uniforms u_occupancy, in volume_uniforms u_volume, in sampler2D sampler_occupancy, in vec3 ray_position, in vec3 ray_step, out float skip_steps)
{
    // calculate normalized block size
    vec3 block_size = u_occupancy.block / u_volume.dimensions;

    // find the current block index in the volume
    vec3 block_index = floor(ray_position / block_size);

    // compute block voxel min and max coordinates in the volume
    vec3 voxel_min = block_index * block_size;
    vec3 voxel_max = voxel_min + block_size;

    // clamp in normalized coordinates
    voxel_min = max(voxel_min, 0.0);
    voxel_max = min(voxel_max, 1.0);

    // intersect ray with block and compute skip steps
    float distance = intersect_box_max(voxel_min, voxel_max, ray_position, ray_step); // gl_FragColor = vec4(vec3(distance/length(u_occupancy.block) * length(ray_step)), 1.0);
    skip_steps = max(floor(distance), 0.0); //  gl_FragColor = vec4(vec3(skip_steps)/(length(u_occupancy.block / u_volume.dimensions) / length(ray_step)), 1.0);

    // compute the block position in the occupancy map's normalized coordinates
    vec3 block_uvw = (block_index + 0.5) / u_occupancy.size;
    vec2 block_uv = reshape_3d_to_2d_texel(block_uvw, u_occupancy.size);

    // sample the occupancy map at the block position
    // if the sampled value is greater than 0, the block is occupied
    float occupied_intensity = sample_intensity_2d(sampler_occupancy, block_uv);
    bool occupied = occupied_intensity > 0.0;

    return occupied;
    
}
