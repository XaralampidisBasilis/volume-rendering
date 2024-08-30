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
bool raymarch_block
(
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray,
    inout parameters_trace trace,
    int start_step,
    int num_steps
) 
{ 
    // Raymarch loop to traverse through the volume
    for (int i_step = start_step; i_step < num_steps && trace.depth < ray.bounds.y; i_step++) 
    {
        // Sample the intensity of the volume at the current ray position
        trace.value = texture(u_sampler.volume, trace.position).r;

        // Extract gradient and value from texture data
        vec4 gradient_data = texture(u_sampler.gradients, trace.position);
        trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
        trace.steepness = gradient_data.a;

        // Check if the sampled intensity exceeds the threshold
        if (trace.value > u_raycast.threshold && trace.steepness > u_gradient.threshold) 
        {
            // Compute refinement
            compute_refinement(u_raycast, u_gradient, u_sampler, ray, trace);
            return true;
        }

        // Update ray position for the next step
        trace.position += ray.step;
        trace.depth += ray.spacing;
    }   

    return false;
}
