#include "./compute_skipping"

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
bool raymarch_skip
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
    float nudge = mmin(u_volume.spacing * u_occupancy.block_dimensions) * 0.001;
    float backstep = ray.max_spacing + ray.dithering;
    float skip_distance;

    for (
        trace.steps = 0; 
        trace.steps < ray.max_steps && trace.distance < ray.max_distance; 
        trace.steps++
    ) 
    {
        // check if the current block is occupied and compute skip depth
        bool occupied = compute_skipping(u_sampler.occumap, u_occupancy, u_volume, ray, trace, skip_distance);
        float max_distance = min(trace.distance + skip_distance, ray.max_distance);

        // if block occupied traverse
        if (occupied) 
        {            
            // adjust the trace depth and position by backstepping
            trace.distance -= backstep;
            trace.position = ray.origin + ray.direction * trace.distance;

            skip_distance += backstep;
            int max_steps = int(ceil(skip_distance / ray.min_spacing));

            // traverse through occupied block
            for(int i = 0; i < max_steps && trace.distance < max_distance; i++, trace.steps++) 
            {
                // sample the volume and compute intensity at the current position
                trace.texel = trace.position * u_volume.inv_size;
                trace.value = texture(u_sampler.volume, trace.texel).r;
                trace.error = trace.value - u_raycast.threshold;

                // sample the gradients and compute normal and gradient vectors
                vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
                trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
                trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
                trace.gradient = - trace.normal * trace.gradient_norm;
                trace.derivative = dot(trace.gradient, ray.direction);

                // if intensity exceeds threshold and gradient is strong enough, refine the hit
                // first iteration is skipped in order to compute previous trace and we are outside of occupied block
                if (trace.error > 0.0 && gradient_data.a > u_gradient.threshold && i > 0)
                {   
                    compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);            
                    return true;
                }

                // prepare for the next step, update trace and ray position
                copy_trace(prev_trace, trace);
                trace.spacing = ray.spacing * compute_stepping(u_raycast, u_gradient, ray, trace);
                trace.position += ray.direction * trace.spacing;
                trace.distance += trace.spacing;
            }       
        }

        // Skip the block and adjust depth with a small nudge to avoid precision issues
        trace.skipped += mix(skip_distance, 0.0, occupied);
        trace.distance = max_distance + nudge;
        trace.position = ray.origin + ray.direction * trace.distance;
    }   

    return false;
}