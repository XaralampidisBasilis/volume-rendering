#include "./modules/compute_bounds"
#include "../dither/compute_dither"
#include "../step/compute_step"
#include "../raymarch/compute_raymarch"

/**
 * Performs raycasting in a 3D texture to find the depth and intensity of an intersection.
 *
 * @param u_gradient: Struct containing gradient-related uniforms.
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param u_occupancy: Struct containing occupancy-related uniforms.
 * @param u_sampler: Struct containing sampler-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return bool: Returns true if an intersection is found above the threshold, false otherwise.
 */
bool compute_raycast
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray,
    inout parameters_trace trace
) {    
    // Compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
    ray.bounds = compute_bounds(u_occupancy.box_min, u_occupancy.box_max, ray.origin, ray.direction); // debug gl_FragColor = vec4(vec3((ray.bounds.y - ray.bounds.x) / 1.732), 1.0);  
    ray.span = ray.bounds.y - ray.bounds.x;

    // Compute the ray step vector based on the raycast and volume parameters.
    ray.step = compute_step(u_raycast, u_volume.dimensions, ray.direction, ray.span); 
    ray.delta = length(ray.step);

    // Apply dithering to the initial distance to avoid artifacts.
    ray.dither = compute_dither(u_raycast, u_sampler.noisemap, u_volume.size, ray.direction, ray.bounds); // debug gl_FragColor = vec4(vec3(ray.dither), 1.0); 
    ray.dither *= ray.delta;
    ray.dither *= u_raycast.dithering;

    // Compute the max number of steps in the worst case
    ray.num_steps = int(((ray.span - ray.dither) / ray.delta) * u_raycast.resolution_max); // debug gl_FragColor = vec4(vec3(num_steps) * ray.delta / 1.732, 1.0);  

    // Initialize trace starting position along the ray.
    trace.distance = ray.bounds.x + ray.dither;
    trace.position = ray.origin + ray.direction * trace.distance;
    
    // Raycasting loop to traverse through the volume and find intersections.
    return compute_raymarch(u_gradient, u_raycast, u_occupancy, u_sampler, ray, trace);
}
