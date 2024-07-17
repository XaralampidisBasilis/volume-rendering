#include ./modules/check_occupancy.glsl;
#include ./modules/check_intersection.glsl;
#include ./modules/refine_intersection.glsl;
#include ./modules/compute_frag_depth.glsl;

#include ./marching_no_skip.glsl;
#include ./marching_skip.glsl;

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
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in ivec2 step_bounds,
    in vec3 ray_step,
    in vec3 ray_position,
    out vec3 hit_position,
    out float hit_sample,
    out float hit_depth
) 
{
    switch(u_raycast.skipping)  
    {
        case 0:
            return marching_no_skip(u_raycast, u_volume, u_occupancy, u_sampler, step_bounds, ray_step, ray_position, hit_position, hit_sample, hit_depth);
        case 1:
            return marching_skip(u_raycast, u_volume, u_occupancy, u_sampler, step_bounds, ray_step, ray_position, hit_position, hit_sample, hit_depth);
        default:
            return false;
    }  
}