#include ../raycast/dithering.glsl;
#include ../raycast/refine.glsl;
#include ../utils/sample_intensity.glsl;

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
bool raycast(in raycast_uniforms u_raycast, in volume_uniforms u_volume, in vec3 ray_start, in vec3 ray_normal, in vec2 ray_bounds, out vec3 hit_position, out float hit_value) 
{    
    // compute ray step
    step()

    // Apply dithering to the initial distance
    step_bounds.x -= dither(u_raycast, ray_step, step_bounds);  /* need to fix dithering uv vector from direction.xy or v_position.xy becouse there are artifacts */

    // Starting position along the ray
    hit_position = ray_start + ray_step * step_bounds.x;
    
    // Raycasting loop
    for (float step = step_bounds.x; step < step_bounds.y; step++) {

        hit_value = sample_intensity(u_volume.data, hit_position);          // Sample value from the 3D texture at the current position
        
        if (hit_value > uniforms.threshold) {

            refine(u_raycast, volume_data, ray_step, hit_position, hit_value);
            return true;
        }

        hit_position += ray_step;                             // Move position forward by main step
    }   

    // if no hit found
    hit_value = 0.0;                                          
    return false;
}

