/**
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

#include ./modules/check_intersection.glsl;
#include ./modules/check_occupancy_block.glsl;
#include ./modules/check_occupancy_linear.glsl;

bool raymarch_skip
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray,
    inout parameters_trace trace
) 
{ 
    int skip_steps = 0;
    for (int i_step = 0; i_step < ray.num_steps && trace.depth < ray.bounds.y; i_step++) 
    {
        // traverse space if block is occupied
        bool occupied = check_occupancy(u_occupancy, u_volume, u_sampler, ray.position, ray.step, skip_steps);

        if (occupied) 
        {            
           
        }
        else 
        {
            // skip space
            i_step += skip_steps;
            ray.position += ray.step * float(skip_steps);
            trace.depth += ray.spacing * spacing_factor;
        }
    }   

    return false;
}