
#include ../uniforms/raycast_volume_fast.glsl;
#include ./dithering.glsl;
#include ./check_block_occupancy.glsl;
#include ./refine_hit.glsl;

bool raycast_block(in sampler3D data, in vec3 start, in vec3 ray_step, in float exit_steps, in float threshold, out vec3 position, out float value);

/**
 * Performs raycasting in a 3D texture to find the depth and value of an intersection.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param start: Starting point of the ray in normalized texture coordinates
 * @param direction: Direction vector of the ray in normalized texture coordinates
 * @param range: vec2 containing the start and end distances for raycasting
 * @param size: the size of the volume texture
 * @param position: Output vec3 where the position of the intersection will be stored
 * @param value: Output float where the value at the intersection will be stored
 */

bool raycast_volume_fast(sampler3D volume_data, vec3 ray_start, vec3 ray_step, vec2 steps_range, out vec3 position, out float value) 
{
    // apply dithering 
    steps_range.x += dithering(u_noisemap_data, ray_step, steps_range) * u_raycast_dithering; 

    // raycast loop
    float steps = steps_range.x;
    float count = 0.0;
    float count_max = u_occupancy_size.x + u_occupancy_size.y + u_occupancy_size.z;
    
    // initialize position and depth
    position = ray_start + ray_step * steps; 

    while (steps < steps_range.y && count < count_max) {

        // check block occupacy
        float exit_steps = 0.0;
        bool occupied = check_block_occupancy(u_occupancy_data, u_occupancy_size, u_occupancy_block, position, ray_step, exit_steps);

        if (occupied) {

            bool hit = raycast_block(volume_data, position, ray_step, exit_steps, u_raycast_threshold, position, value);

            if (hit) 
            {
                // refine_hit(volume_data, position, ray_step, u_raycast_threshold, u_raycast_refinements, position, value);             
                return true;
            }
        }
        else
        {
            // Move to next block
            steps += exit_steps;
            position += exit_steps * ray_step;
        }

        count++;
    }   

    // Set value to 0 if no intersection is found
    value = 0.0;                               
    return false;
}

bool raycast_block(in sampler3D data, in vec3 start, in vec3 ray_step, in float exit_steps, in float threshold, out vec3 position, out float value)
{
    position = start;
    value = 0.0;

    for (float i = 0.0; i < exit_steps; i++) {

        value = texture(data, position).r;      // Sample value from the 3D texture at the current position

        if (value > threshold) 
            return true;

        position += ray_step; // Sample value from the 3D texture at the current position
    }

    return false;
}
