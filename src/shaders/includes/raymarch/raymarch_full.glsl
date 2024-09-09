/**
 * Performs ray marching to traverse through the volume and find the depth and intensity of an intersection.
 *
 * @param u_gradient: Struct containing gradient-related uniforms.
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_sampler: Struct containing sampler-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, position, step, etc.).
 * @param trace: Struct to hold the information about the intersection (position, normal, value, gradient, etc.).
 * @return bool: Returns true if an intersection is found above the threshold, false otherwise.
 */
bool raymarch_full
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray,
    inout parameters_trace trace,
    inout parameters_trace prev_trace
) 
{ 
    // Raymarch loop to traverse through the volume
    for (
        trace.i_step = 0; 
        trace.i_step < u_raycast.max_steps && trace.depth < ray.bounds.y; 
        trace.i_step++
    ) 
    {
        // Sample the intensity of the volume at the current ray position
        trace.texel = trace.position * u_volume.inv_size;
        trace.value = texture(u_sampler.volume, trace.texel).r;
        trace.error = trace.value - u_raycast.threshold;

        // Extract gradient and value from texture data
        vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
        trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
        trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
        trace.gradient = - trace.normal * trace.steepness;

        // Check if the sampled intensity exceeds the threshold
        if (trace.error > 0.0 && gradient_data.a > u_gradient.threshold) 
        {   
            // Compute refinement
            compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);            
            return true;
        }

        // Save previous trace
        prev_trace.value = trace.value;
        prev_trace.gradient = trace.gradient;
        prev_trace.depth = trace.depth;
        prev_trace.position = trace.position;
        prev_trace.texel = trace.texel;

        // Update ray position for the next step
        trace.spacing = ray.spacing * compute_stepping(u_raycast, u_gradient, ray, trace);
        trace.position += ray.direction * trace.spacing;
        trace.depth += trace.spacing;
    }   

    return false;
}
