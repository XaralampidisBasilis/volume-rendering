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
    inout parameters_ray ray
) 
{ 
    // initialize state vaiables
    int skip_steps[3] = int[3](0, 0, 0);
    int current_level = 0;
    int next_level = 0;

    // raymarch loop to traverse through the volume
    float MAX_COUNT = 1.73205080757 / length(ray.step); // for some reason some rays do not terminate. Need to find why
    float count = 0.0;

    for (int i_step = ray.step_bounds.x; i_step < ray.step_bounds.y && count < MAX_COUNT; count++) 
    {
        // traverse space if block is occupied
        bool occupied = check_occupancy_linear(u_occupancy, u_volume, u_sampler, ray.position, ray.step, skip_steps, current_level, next_level);
        if (occupied) 
        {            
            // terminate marching if ray  hit
            bool intersected = check_intersection(u_gradient, u_raycast, u_sampler, u_volume, ray.step, skip_steps[current_level], ray_position, hit_position, hit_normal, hit_sample, hit_depth);
            if (intersected) 
            {
                // gl_FragColor = vec4(vec3(count/MAX_COUNT), 1.0);
                return true;
            }
        }
        
        // update ray and skip space
        i_step += skip_steps[current_level];
        ray.position += ray_step * float(skip_steps[current_level]);
        current_level = next_level;
    }   

    return false;
}