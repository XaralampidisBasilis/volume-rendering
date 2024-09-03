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
    inout parameters_trace trace
) {    
    // Compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
    ray.bounds = compute_bounds(u_volume.size, u_occupancy.box_min, u_occupancy.box_max, ray.origin, ray.direction); 
    ray.span = ray.bounds.y - ray.bounds.x;
    // gl_FragColor = vec4(vec3(ray.bounds.x / ray.bounds.y), 1.0); return true;
    // gl_FragColor = vec4(vec3(ray.span / length(u_volume.size)), 1.0); return true;

    // Compute the ray step vector based on the raycast and volume parameters.
    ray.spacing = compute_spacing(u_raycast.spacing_method, u_volume, ray); 
    ray.max_steps = int(ray.span / (ray.spacing * u_raycast.stepping_min));
    ray.step = ray.direction * ray.spacing;
    // gl_FragColor = vec4(vec3(ray.spacing / length(u_volume.spacing)), 1.0); return true;
    // gl_FragColor = vec4(vec3(ray.direction * 0.5 + 0.5), 1.0); return true;

    // Apply dithering to the initial distance to avoid artifacts.
    ray.dithering = compute_dithering(u_raycast.dithering_method, u_sampler.noisemap, ray); 
    ray.dithering *= ray.spacing * u_raycast.stepping_min * u_raycast.has_dithering; // should i use stepping min or max?
    // gl_FragColor = vec4(vec3(ray.dithering / ray.spacing), 1.0); return true;

    // Initialize trace starting position along the ray.
    ray.span -= ray.dithering;
    trace.depth = ray.bounds.x + ray.dithering;
    trace.position = ray.origin + ray.direction * trace.depth;
    trace.spacing = ray.spacing;
    // gl_FragColor = vec4(vec3(trace.position / u_volume.size), 1.0); return true;
    
    // Raycasting loop to traverse through the volume and find intersections.
    return compute_raymarch(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace);
}
