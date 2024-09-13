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
) 
{        
    // set ray bounding box
    ray.box_min = mix(ray.box_min, u_occupancy.box_min, u_raycast.has_bbox);
    ray.box_max = mix(ray.box_max, u_occupancy.box_max, u_raycast.has_bbox);

    // compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
    vec2 ray_bounds = compute_bounds(ray.box_min, ray.box_max, ray.origin, ray.direction); 
    ray.min_distance = ray_bounds.x;
    ray.max_distance = ray_bounds.y;
    ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);
    // if (ray.max_depth < 0.0) discard;

    // compute the ray step vector based on the raycast and volume parameters.
    ray.spacing = compute_spacing(u_raycast.spacing_method, u_volume, ray); 
    ray.min_spacing = ray.spacing * u_raycast.min_stepping;
    ray.max_spacing = ray.spacing * u_raycast.max_stepping;
    ray.max_steps = int(ray.max_depth / ray.min_spacing);
    ray.max_steps = min(ray.max_steps, u_raycast.max_steps);

    // apply dithering to the initial distance to avoid artifacts.
    ray.dithering = compute_dithering(u_raycast.dithering_method, u_sampler.noisemap, ray); 
    ray.dithering *= ray.max_spacing * u_raycast.has_dithering;
    ray.max_depth += ray.dithering;

    // initialize trace starting position along the ray.
    trace.distance = ray.min_distance - ray.dithering;
    trace.position = ray.origin + ray.direction * trace.distance;
    trace.spacing = ray.spacing;
    
    // raycasting loop to traverse through the volume and find intersections.
    return compute_raymarch(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace, prev_trace);
}
