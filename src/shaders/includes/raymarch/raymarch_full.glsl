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
    inout parameters_trace trace
) 
{ 
    // Raymarch loop to traverse through the volume
    for (trace.i_step = 0; trace.i_step < ray.max_steps && trace.depth < ray.bounds.y; trace.i_step++) 
    {
        // Sample the intensity of the volume at the current ray position
        trace.texel = trace.position * u_volume.inv_size;
        trace.value = texture(u_sampler.volume, trace.texel).r;

        // Extract gradient and value from texture data
        trace.gradial_data = texture(u_sampler.gradients, trace.texel);
        trace.normal = normalize(1.0 - 2.0 * trace.gradial_data.rgb);
        trace.steepness = trace.gradial_data.a * u_gradient.length_range + u_gradient.min_length;
        trace.gradient = - trace.normal * trace.steepness;

        // Check if the sampled intensity exceeds the threshold
        if (trace.value > u_raycast.threshold && trace.gradial_data.a > u_gradient.threshold) 
        {
            // Compute refinement
            compute_refinement(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
            return true;
        }

        // Compute adaptive resolution based on gradient
        float stepping = compute_stepping(u_raycast, ray, trace);

        // Update ray position for the next step
        trace.position += ray.step * stepping;
        trace.depth += ray.spacing * stepping;
    }   

    return false;
}
