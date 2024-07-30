/**
 * Performs ray marching to traverse through the volume and find the depth and intensity of an intersection.
 *
 * @param u_gradient: Struct containing gradient-related uniforms.
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param u_sampler: Struct containing sampler-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, position, step, etc.).
 * @return bool: Returns true if an intersection is found above the threshold, false otherwise.
 */
bool marching_full
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
    for (int i_step = 0; i_step < ray.num_steps; i_step++) 
    {
        // Sample the intensity of the volume at the current ray position
        vec4 texture_data = texture(u_sampler.volume, trace.position);

        // Get sample and gradient from texture data
        trace.gradient = texture_data.gba * 2.0 - 1.0;
        trace.slope = length(trace.gradient);
        trace.value = texture_data.r;

        // Check if the sampled intensity exceeds the threshold
        if (trace.value > u_raycast.threshold && trace.slope > u_gradient.threshold) 
        {
            // Refine the hit position
            // refine_intersection(u_raycast, u_gradient, u_sampler, ray);
            
            // Compute trace distance at intersection
            trace.distance = distance(trace.position, ray.origin);

            // Compute trace normal vector at intersection
            trace.normal = -normalize(trace.gradient);

            return true;
        }

        // Compute adaptive resolution based on gradient
        float resolution = compute_resolution(u_raycast, ray.direction, trace.gradient);

        // Update ray position for the next step
        trace.position += ray.step / resolution;
    }   

    return false;
}
