uniform sampler2D u_noisemap_data;
uniform sampler2D u_occupancy_data;
uniform vec3 u_occupancy_size;
uniform vec3 u_occupancy_block;
uniform float u_raycast_threshold;  
uniform int u_raycast_refinements;  
uniform float u_raycast_dithering;

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

bool raycast_volume_fast(sampler3D volume_data, vec3 ray_start, vec3 ray_step, vec2 range, out vec3 position, out float value) 
{
    // apply dithering 
    range.x += dithering(u_noisemap_data, ray_step, range) * u_raycast_dithering; 

    // raycast loop
    float steps = range.x;
    float count = 0.0;
    
    // initialize position and depth
    position = ray_start + ray_step * steps; 

    while ((steps < range.y) && (count < 1000.0)) {

    // for (float steps = range.x; steps < range.y; steps++) {

        // check block occupacy
        float exit_steps = 0.0;
        bool occupied = check_block_occupancy(u_occupancy_data, u_occupancy_size, u_occupancy_block, position, ray_step, exit_steps);

        if (occupied) {

            bool hit = raycast_block(volume_data, position, ray_step, exit_steps, u_raycast_threshold, position, value);

            if (hit) 
            {
                gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
                // refine_hit(volume_data, position, ray_step, u_raycast_threshold, u_raycast_refinements, position, value);             

                return true;
            }
        }
        else
        {
            // Move to next block
            steps += exit_steps;
            position =+ exit_steps * ray_step;
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
