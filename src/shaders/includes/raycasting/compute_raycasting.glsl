#include "./modules/compute_bounds"
#include "../dithering/compute_dithering"
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
bool compute_raycasting
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray,
    inout parameters_trace trace,
    inout parameters_trace prev_trace
) {    
    // Compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
    ray.bounds = compute_bounds(u_raycast.has_bbox, u_volume.size, u_occupancy.box_min, u_occupancy.box_max, ray.origin, ray.direction); 
    ray.span = ray.bounds.y - ray.bounds.x;

    // Compute the ray step vector based on the raycast and volume parameters.
    ray.spacing = compute_spacing(u_raycast.spacing_method, u_volume, ray); 
    ray.min_spacing = ray.spacing * u_raycast.min_stepping;
    ray.max_spacing = ray.spacing * u_raycast.max_stepping;
    ray.max_steps = int(ray.span / ray.min_spacing);
    ray.step = ray.direction * ray.spacing;

    // Apply dithering to the initial distance to avoid artifacts.
    ray.dithering = compute_dithering(u_raycast.dithering_method, u_sampler.noisemap, ray); 
    ray.dithering *= ray.max_spacing * u_raycast.has_dithering;

    // Initialize trace starting position along the ray.
    ray.span += ray.dithering;
    trace.depth = ray.bounds.x - ray.dithering;
    trace.position = ray.origin + ray.direction * trace.depth;
    trace.spacing = ray.spacing;
    
    // Raycasting loop to traverse through the volume and find intersections.
    return compute_raymarch(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace, prev_trace);
}
