uniform float u_raycast_threshold;  // Threshold value to determine if the ray has hit an object
uniform int u_raycast_refinements;  // Number of refinements for raycasting precision
uniform float u_raycast_dithering;
uniform sampler2D u_noisemap_data;

#include ./dithering.glsl;
#include ./refine_hit.glsl;
#include ../utils/rand.glsl;

/**
 * Performs raycasting in a 3D texture to find the depth and value of an intersection.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param orig: Starting point of the ray
 * @param dir: Direction vector of the ray
 * @param range: vec2 containing the start and end distances for raycasting
 * @param step: Step vector for raycasting increments
 * @param depth: Output float where the depth of the intersection will be stored
 * @param value: Output float where the value at the intersection will be stored
 */
bool raycast_volume(in sampler3D data, in vec3 start, in vec3 step, in vec2 range, out vec3 position, out float value) 
{    
    // Apply dithering to the initial distance
    range.x -= dithering(u_noisemap_data, step, range) * u_raycast_dithering;  /* need to fix dithering uv vector from direction.xy or v_position.xy becouse there are artifacts */

    // Starting position along the ray
    position = start + step * range.x; 
    
    // Raycasting loop
    for (float steps = range.x; steps < range.y; steps++) {

        value = texture(data, position).r;          // Sample value from the 3D texture at the current position
        
        if (value > u_raycast_threshold) {

            refine_hit(data, position, step, u_raycast_threshold, u_raycast_refinements, position, value);
            return true;
        }

        position += step;                             // Move position forward by main step
    }   

    // if no hit found
    value = 0.0;                                          
    return false;
}

