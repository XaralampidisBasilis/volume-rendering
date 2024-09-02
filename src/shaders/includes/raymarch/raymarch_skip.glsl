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

#include ./modules/check_occupancy.glsl;

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
    for (trace.i_step = 0; trace.i_step < ray.max_steps && trace.depth < ray.bounds.y; /*trace.i_step++*/) 
    {
        // traverse space if block is occupied
        bool occupied = check_occupancy(u_sampler.occumap, u_occupancy, u_volume, ray, trace, skip_steps);
        if (occupied) 
        {            
            // Raymarch loop to traverse through the volume
            for (int n = 0; n < skip_steps && trace.depth < ray.bounds.y; n++) 
            {
                // Calculate texel position once and reuse
                trace.texel = trace.position * u_volume.inv_size;
                trace.value = texture(u_sampler.volume, trace.texel).r;

                // Extract gradient and value from texture data
                vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
                trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
                trace.steepness = gradient_data.a * u_gradient.length_range + u_gradient.min_length;
                trace.gradient = trace.normal * trace.steepness;
                
                // Check if the sampled intensity exceeds the threshold
                if (trace.value > u_raycast.threshold && gradient_data.a > u_gradient.threshold) 
                {
                    // Compute refinement
                    // compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
                    return true;
                }

                // Update ray trace
                trace.i_step += 1;
                trace.position += ray.step;
                trace.depth += ray.spacing;
            }   
            
            // Update position after the inner loop
            trace.i_step += 1;
            trace.position += ray.step;
            trace.depth += ray.spacing;        
        }
        else 
        {
            // skip space
            trace.i_step += skip_steps;
            trace.position += ray.step * float(skip_steps);
            trace.depth += ray.spacing * float(skip_steps);
        }
    }   

    return false;
}