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
    inout parameters_ray ray
) 
{ 
    // Raymarch loop to traverse through the volume
    for (int i_step = 0; i_step < ray.num_steps; i_step++) 
    {
        // Sample the intensity of the volume at the current ray position
        vec4 texture_data = texture(u_sampler.volume, ray.position);

        // Get sample and gradient from texture data
        vec3 gradient = texture_data.gba * 2.0 - 1.0;
        float slope = length(gradient);
        ray.value = texture_data.r;

        // Check if the sampled intensity exceeds the threshold
        if (ray.value > u_raycast.threshold && slope > u_gradient.threshold) 
        {
            // Refine the hit position
            // refine_intersection(u_raycast, u_gradient, u_sampler, ray);

            // Compute fragment depth at hit position
            ray.depth = compute_frag_depth(u_volume.size, ray.position);    
            ray.normal = -normalize(gradient);

            return true;
        }

        // Compute adaptive resolution based on gradient
        float resolution = compute_resolution(u_raycast, ray, gradient);

        // Update ray position for the next step
        ray.position += ray.step / resolution;
    }   

    return false;
}
