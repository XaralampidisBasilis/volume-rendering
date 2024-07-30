#include "./modules/compute_bounds"
#include "../dithering/compute_dithering"
#include "../stepping/compute_stepping"
#include "../marching/compute_marching"

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
    inout parameters_ray ray
) {    
    // Compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
    ray.bounds = compute_bounds(u_occupancy.box_min, u_occupancy.box_max, ray.origin, ray.direction); // debug gl_FragColor = vec4(vec3((ray.bounds.y - ray.bounds.x) / 1.732), 1.0);  
    ray.span = ray.bounds.y - ray.bounds.x;

    // Compute the ray step vector based on the raycast and volume parameters.
    ray.step = compute_stepping(u_raycast, u_volume, ray); 
    ray.delta = length(ray.step);

    // Apply dithering to the initial distance to avoid artifacts.
    ray.dither = compute_dithering(u_raycast, u_volume, u_sampler, ray); // debug gl_FragColor = vec4(vec3(ray.dither), 1.0);  
    ray.dither *= u_raycast.dithering;

    // Initialize the starting position along the ray.
    ray.position = ray.origin + ray.direction * ray.bounds.x;
    ray.position += ray.dither * ray.step;
    ray.span -= ray.dither * ray.delta;
    
    // Compute the max number of steps in the worst case
    ray.num_steps = int((ray.span / ray.delta) * u_raycast.resolution_max); // debug gl_FragColor = vec4(vec3(num_steps) * ray.delta / 1.732, 1.0);  

    // Raycasting loop to traverse through the volume and find intersections.
    return compute_marching(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray);
}
