#include "./modules/compute_resolution"
#include "./modules/compute_frag_depth"
#include "./modules/refine_intersection"
#include "./marching_full"
// #include "./marching_skip"

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
bool compute_marching
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray
) 
{
    switch(u_raycast.skipping)  
    {
        case 0:
            return marching_full(u_gradient, u_raycast, u_volume, u_sampler, ray);
        default:
            return false;
    }  
}