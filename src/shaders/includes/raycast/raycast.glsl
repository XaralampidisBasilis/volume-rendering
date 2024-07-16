#include ../raycast/raystep/raystep.glsl;
#include ../raycast/raymarch/raymarch.glsl;
#include ../raycast/bounds.glsl;
#include ../raycast/dither.glsl;

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
    in vec3 ray_origin, 
    in vec3 ray_normal, 
    out vec3 ray_position, 
    out float ray_sample
) {    
    // compute the intersection bounds of a ray with occypancy axis-aligned bounding box.
    vec2 ray_bounds = bounds(u_occupancy, ray_origin, ray_normal); // debug gl_FragColor = vec4(vec3((ray_bounds.y-ray_bounds.x) / 1.732), 1.0);  

    // compute the ray step vector based on the raycast and volume parameters
    vec3 ray_step = raystep(u_raycast, u_volume, ray_normal, ray_bounds); 

    // apply dithering to the initial distance to avoid artifacts
    float ray_dither = dither(u_raycast, u_sampler, ray_normal, ray_bounds); // debug gl_FragColor = vec4(vec3(ray_dither), 1.0);  

    // initialize the starting position along the ray
    ray_position = ray_origin + ray_bounds.x * ray_normal - ray_dither * ray_step;
    
    // compute the ray step delta and step bounds
    ivec2 step_bounds = ivec2(ray_bounds / length(ray_step)); // debug gl_FragColor = vec4((step_bounds.y-step_bounds.x)*ray_delta/1.732, 1.0);  

    // raycasting loop to traverse through the volume
    return raymarch(u_raycast, u_volume, u_occupancy, u_sampler, step_bounds, ray_step, ray_position, ray_sample);

    // for (float n_step = step_bounds.x; n_step < step_bounds.y; n_step++, hit_position += ray_step) {

    //     // sample the intensity from the 3d texture at the current position
    //     hit_intensity = sample_intensity_3d(u_sampler.volume, hit_position);          
        
    //     // check if the sampled intensity exceeds the threshold
    //     if (hit_intensity > u_raycast.threshold) {

    //         // refine the hit position and intensity
    //         refine(u_raycast, u_sampler, ray_step, hit_position, hit_intensity);
    //         return true; // intersection found
    //     }
    // }   

    // // if no intersection is found, set hit_intensity to 0
    // hit_intensity = 0.0;
    // return false; // no intersection
}
