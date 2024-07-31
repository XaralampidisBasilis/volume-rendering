#include "./modules/compute_bounds"
#include "../dither/compute_dither"
#include "../spacing/compute_spacing"
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
    ray.bounds = compute_bounds(u_occupancy.box_min, u_occupancy.box_max, ray.origin, ray.direction); 
    ray.span = ray.bounds.y - ray.bounds.x;

    // Compute the ray step vector based on the raycast and volume parameters.
    ray.spacing = compute_spacing(u_raycast, u_volume.dimensions, ray.span); 
    ray.step = ray.direction * ray.spacing;

    // Apply dithering to the initial distance to avoid artifacts.
    ray.dither = compute_dither(u_raycast, u_sampler.noisemap, u_volume.size, ray.direction, ray.bounds); 
    ray.dither *= ray.spacing;
    ray.dither *= u_raycast.dithering;

    // Compute the max number of steps in the worst case
    ray.span += ray.dither;
    ray.num_steps = int(ray.span / ray.spacing / u_raycast.spacing_min);

    // Initialize trace starting position along the ray.
    trace.depth = ray.bounds.x - ray.dither;
    trace.position = ray.origin + ray.direction * trace.depth;
    
    // Raycasting loop to traverse through the volume and find intersections.
    return compute_raymarch(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace);
}
