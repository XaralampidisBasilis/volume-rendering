#include ../raycast/stride.glsl
#include ../raycast/dithering.glsl
#include ../raycast/refine.glsl
#include ../../utils/sample_intensity.glsl

/**
 * performs raycasting in a 3d texture to find the depth and value of an intersection.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param ray_start: starting point of the ray.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @param hit_position: output vec3 where the position of the intersection will be stored.
 * @param hit_value: output float where the value at the intersection will be stored.
 * @return bool: returns true if an intersection is found above the threshold, false otherwise.
 */
bool raycast(in raycast_uniforms u_raycast, in volume_uniforms u_volume, in vec3 ray_start, in vec3 ray_normal, in vec2 ray_bounds, out vec3 hit_position, out float hit_value) 
{    
    // compute the ray step vector based on the raycast and volume parameters
    vec3 ray_step = stride(u_raycast, u_volume, ray_normal, ray_bounds);

    // compute the ray step delta and step bounds
    float ray_delta = length(ray_step); 
    vec2 step_bounds = ray_bounds / ray_delta; 

    // apply dithering to the initial distance to avoid artifacts
    step_bounds.x -= dither(u_raycast, ray_normal, ray_bounds) * ray_delta;

    // initialize the starting position along the ray
    hit_position = ray_start + ray_step * step_bounds.x;
    
    // raycasting loop to traverse through the volume
    for (float step = step_bounds.x; step < step_bounds.y; step++) {

        // sample the value from the 3d texture at the current position
        hit_value = sample_intensity(u_volume.data, hit_position);          
        
        // check if the sampled value exceeds the threshold
        if (hit_value > u_raycast.threshold) {

            // refine the hit position and value
            refine(u_raycast, u_volume, ray_step, hit_position, hit_value);
            return true; // intersection found
        }

        // move the position forward by the step vector
        hit_position += ray_step;
    }   

    // if no intersection is found, set hit_value to 0
    hit_value = 0.0;
    return false; // no intersection
}
