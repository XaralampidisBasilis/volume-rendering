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
    // take a backstep in order to compute initial prev_trace
    trace.distance -= ray.max_spacing;
    trace.position = ray.origin + ray.direction * trace.distance;

    // Raymarch loop to traverse through the volume
    for (
        trace.steps = 0; 
        trace.steps < ray.max_steps && trace.distance < ray.max_distance; 
        trace.steps++
    ) 
    {
        // Sample the intensity of the volume at the current ray position
        trace.texel = trace.position * u_volume.inv_size;
        trace.value = texture(u_sampler.volume, trace.texel).r;
        trace.error = trace.value - u_raycast.threshold;

        // Extract gradient and value from texture data
        vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
        trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
        trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
        trace.gradient = - trace.normal * trace.gradient_norm;
        trace.derivative = dot(trace.gradient, ray.direction);

        // Check if the sampled intensity exceeds the threshold
        if (trace.error > 0.0 && gradient_data.a > u_gradient.threshold && trace.steps > 0) 
        {   
            // Compute refinement
            compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);            
            return true;
        }

        // Update ray position for the next step
        copy_trace(prev_trace, trace);
        trace.spacing = ray.spacing * compute_stepping(u_raycast, u_gradient, ray, trace);
        trace.distance += trace.spacing;
        trace.position += ray.direction * trace.spacing;
    }   

    return false;
}
