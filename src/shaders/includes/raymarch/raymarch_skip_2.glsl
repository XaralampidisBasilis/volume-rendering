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

#include ./modules/compute_skipping_2.glsl;

bool raymarch_skip_2
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
    float skip_depth;
    int debug_iter = 0;

    for (
        trace.i_step = 0; 
        trace.i_step < ray.max_steps && trace.depth < ray.bounds.y && debug_iter < u_debug.iterations; 
        trace.i_step++, debug_iter++
    ) 
    {
        // traverse space if block is occupied
        bool occupied = compute_skipping_2(u_sampler.occumap, u_occupancy, u_volume, ray, trace, skip_depth);
        float max_depth = min(skip_depth + trace.depth, ray.bounds.y);

        if (occupied) 
        {            
            int max_steps = max(int(ceil(skip_depth / (ray.spacing * u_raycast.stepping_min))), 1);

            // Raymarch loop to traverse through the volume
            for(int i = 0; i < max_steps && trace.depth < max_depth; i++) 
            {
                // Calculate texel position once and reuse
                trace.texel = trace.position * u_volume.inv_size;
                trace.value = texture(u_sampler.volume, trace.texel).r;

                // Extract gradient and value from texture data
                vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
                trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
                trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
                trace.gradient = trace.normal * trace.steepness;
                  
                // Check if the sampled intensity exceeds the threshold
                if (trace.value > u_raycast.threshold && gradient_data.a > u_gradient.threshold) 
                {
                    // Compute refinement
                    compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
                    return true;
                }

                // Compute adaptive resolution based on gradient
                trace.spacing = ray.spacing * compute_stepping(u_raycast, ray, trace);

                // Update ray position for the next step
                trace.depth += trace.spacing;
                trace.position += ray.direction * trace.spacing;
                trace.i_step++;
            }       
        }

        // skip space
        trace.depth = max_depth + ray.dithering;
        trace.position = ray.origin + ray.direction * trace.depth;
    }   

    return false;
}