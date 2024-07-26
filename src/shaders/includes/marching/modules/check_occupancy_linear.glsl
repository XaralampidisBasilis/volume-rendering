/**
 * Determines if a block in the volume can be skipped based on an occupancy map
 * and computes the number of steps to exit the block.
 *
 * @param u_occupancy - Uniforms for the occupancy map.
 * @param u_volume - Uniforms for the volume dimensions.
 * @param u_sampler - Uniforms for the sampler.
 * @param ray_position - The current position in the volume (normalized coordinates [0, 1]).
 * @param ray_step - The step vector of the ray.
 * @param current_level - The current level in the occupancy map.
 * @param skip_steps - Array to store the number of steps to exit the block for each level.
 * @param next_level - The next level to traverse if the block is not occupied.
 * @return - Returns true if the block is occupied and the ray should not skip it, false otherwise.
 */
bool check_occupancy_linear
(
    in uniforms_occupancy u_occupancy, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    in vec3 ray_step, 
    inout int skip_steps[3],
    inout int current_level,
    out int next_level
) 
{
    bool occupied[3];
    bool compare_steps[3];

    // Check occupancy for each level and store the results
    occupied[0] = check_occupancy_block(u_sampler.occumaps[0], u_occupancy.dimensions[0], u_occupancy.blocks[0], u_volume.dimensions, ray_position, ray_step, skip_steps[0]);
    occupied[1] = check_occupancy_block(u_sampler.occumaps[1], u_occupancy.dimensions[1], u_occupancy.blocks[1], u_volume.dimensions, ray_position, ray_step, skip_steps[1]);
    occupied[2] = check_occupancy_block(u_sampler.occumaps[2], u_occupancy.dimensions[2], u_occupancy.blocks[2], u_volume.dimensions, ray_position, ray_step, skip_steps[2]);

    // Compute step comparisons
    compare_steps[0] = skip_steps[1] < skip_steps[0];
    compare_steps[1] = skip_steps[2] < skip_steps[1];
    compare_steps[2] = skip_steps[2] < skip_steps[0];

    // Determine if the block is occupied and should not be skipped
    bool occupied_any = occupied[0] || occupied[1] || occupied[2];

    // Calculate the next level based on the comparisons
    next_level = int(compare_steps[1]) + int(compare_steps[2] && !compare_steps[1]);

    // Update the current level based on occupancy results
    current_level = (1 * int(occupied[0] && !occupied[1])) +
                    (2 * int(occupied[1] && !occupied[2]));

    return occupied_any;
}
