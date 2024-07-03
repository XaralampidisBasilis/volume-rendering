#include ../raycast/stride/stride.glsl;
#include ../raycast/bounds.glsl;
#include ../raycast/dither.glsl;
#include ../raycast/refine.glsl;

/**
 * performs raycasting in a 3d texture to find the depth and intensity of an intersection.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param u_occupancy: struct containing occupancy-related uniforms.
 * @param ray_start: starting point of the ray.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @param hit_position: output vec3 where the position of the intersection will be stored.
 * @param hit_intensity: output float where the intensity at the intersection will be stored.
 * @return bool: returns true if an intersection is found above the threshold, false otherwise.
 */
bool raycast
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in vec3 ray_start, 
    in vec3 ray_normal, 
    out vec3 hit_position, 
    out float hit_intensity
) {    
    // compute the intersection bounds of a ray with occypancy axis-aligned bounding box.
    vec2 ray_bounds = bounds(u_occupancy, ray_start, ray_normal); // debug gl_FragColor = vec4(vec3((ray_bounds.y-ray_bounds.x) / 1.732), 1.0);  

    // compute the ray step vector based on the raycast and volume parameters
    vec3 ray_step = stride(u_raycast, u_volume, ray_normal, ray_bounds); 

    // compute the ray step delta and step bounds
    float ray_delta = length(ray_step); 
    vec2 step_bounds = ray_bounds / ray_delta; // debug gl_FragColor = vec4((step_bounds.y-step_bounds.x)*ray_delta/1.732, 1.0);  

    // apply dithering to the initial distance to avoid artifacts
    vec3 dither_step = dither(u_raycast, u_sampler, ray_step, step_bounds); // debug gl_FragColor = vec4(vec3(legth(dither_step)), 1.0);  

    // initialize the starting position along the ray
    hit_position = ray_start + ray_step * step_bounds.x - dither_step;
    
    // raycasting loop to traverse through the volume
    for (float n_step = step_bounds.x; n_step < step_bounds.y; n_step++, hit_position += ray_step) {

        // sample the intensity from the 3d texture at the current position
        hit_intensity = sample_intensity_3d(u_sampler.volume, hit_position);          
        
        // check if the sampled intensity exceeds the threshold
        if (hit_intensity > u_raycast.threshold) {

            // refine the hit position and intensity
            refine(u_raycast, u_sampler, ray_step, hit_position, hit_intensity);
            return true; // intersection found
        }
    }   

    // if no intersection is found, set hit_intensity to 0
    hit_intensity = 0.0;
    return false; // no intersection
}
