#include "../stepping/compute_stepping"
#include "../refinement/compute_refinement"
#include "./modules/raymarch_full"
#include "./modules/raymarch_skip"

/**
 * Determines if a ray intersects with the volume and optionally skips empty space.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param u_occupancy: struct containing occupancy-related uniforms.
 * @param u_sampler: struct containing sampler-related uniforms.
 * @param step_bounds: ivec2 containing the start and end steps for raycasting.
 * @param ray_step: vec3 containing the step vector for the ray.
 * @param ray_position: inout vec3 where the current position of the ray will be updated.
 * @param ray_sample: output float where the sample value at the intersection will be stored.
 * @param ray_depth: output float where the depth at the intersection will be stored.
 * @return bool: returns true if an intersection is found, false otherwise.
 */
bool compute_raymarch
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
    switch(u_raycast.has_skipping)  
    {
        case 0:
            return raymarch_full(u_gradient, u_raycast, u_volume, u_sampler, ray, trace, prev_trace);
        default:
            return raymarch_skip(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace, prev_trace);
    }  
}