/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param u_sampler: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */
void refine_intersection
(
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient, 
    in uniforms_sampler u_sampler, 
    inout parameters_ray ray
)
{
    // Calculate the refined substep based on the number of refinements
    vec3 ray_substep = ray.step / float(u_raycast.refinements + 1);  

    // Step back to refine the hit point
    ray.position -= ray.step;    

    // Perform additional sampling steps to refine the hit point
    for (int i_substep = 0; i_substep <= u_raycast.refinements; i_substep++) 
    {
        // Move position forward by substep
        ray.position += ray_substep;  
        
        // Sample value again with refined position
        vec4 texture_data = texture(u_sampler.volume, ray.position);  

        // Get sample and gradient from texture data
        float derivative = length(texture_data.gba * 2.0 - 1.0);
        ray.value = texture_data.r;

        // If the sampled value exceeds the threshold, return early
        if ( ray.value > u_raycast.threshold && derivative > u_gradient.threshold) 
        {
            ray.normal = normalize(texture_data.gba * 2.0 - 1.0);
            return;   
        }
    }
}
