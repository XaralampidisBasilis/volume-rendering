#include ../spaceskip/blockskip.glsl;

/**
 * Determines if a block in the volume can be skipped based on an occupancy map
 * and computes the number of steps to exit the block.
 *
 * @param u_occupancy - Uniforms for the occupancy map.
 * @param u_volume - Uniforms for the volume dimensions.
 * @param u_sampler - Uniforms for the sampler.
 * @param ray_position - The current position in the volume (normalized coordinates [0, 1]).
 * @param ray_step - The step vector of the ray.
 * @param current_level - The current level in the occumap.
 * @param next_level - The next level to traverse if the block is not occupied.
 * @param skip_steps - Array to store the number of steps to exit the block for each level.
 * @return - Returns true if the block is occupied and the ray should not skip it, false otherwise.
 */
bool spaceskip(
    in uniforms_occupancy u_occupancy, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    in vec3 ray_step, 
    inout float skip_steps[3],
    inout int current_level,
    out int next_level
) {
   
    bool occupied = false;
    
    // Precompute next levels
    float next_levels[3] = float[3](
        0.0,
        step(skip_steps[2], skip_steps[1]),
        step(skip_steps[0], skip_steps[2]) + step(skip_steps[1], skip_steps[2])
    );

    // Iterate through levels without dynamic sampler indexing
    for (int i = current_level; i < 3; i++) {
        switch (i) {
            case 0:
                occupied = blockskip(u_sampler.occumaps[0], u_occupancy.blocks[0], u_volume.dimensions, ray_position, ray_step, skip_steps[0]);
                break;
            case 1:
                occupied = blockskip(u_sampler.occumaps[1], u_occupancy.blocks[1], u_volume.dimensions, ray_position, ray_step, skip_steps[1]);
                break;
            case 2:
                occupied = blockskip(u_sampler.occumaps[2], u_occupancy.blocks[2], u_volume.dimensions, ray_position, ray_step, skip_steps[2]);
                break;
        }

        if (!occupied) 
        {
            next_level = int(next_levels[i]);
            current_level = i;
            return false;
        }
    }

    return true;
}

