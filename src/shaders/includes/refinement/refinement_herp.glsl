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
void refinement_herp
(
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient, 
    in uniforms_sampler u_sampler, 
    inout parameters_ray ray,
    inout parameters_trace trace
)
{
    // Step back to refine the hit point
    trace.position -= ray.step;    

    // Calculate the refined substep based on the number of refinements
    vec3 substep = ray.step / float(u_raycast.refinements + 1);  
   
    // Perform additional sampling steps to refine the hit point
    for (int i_step = 0; i_step <= u_raycast.refinements; i_step++) 
    {
        // Move position forward by substep
        trace.position += substep;  
        
        // Sample value again with refined position
        vec4 texture_data = texture(u_sampler.volume, trace.position);  

        // Extract gradient and value from texture data
        trace.gradient = texture_data.gba * 2.0 - 1.0;
        trace.slope = length(trace.gradient);
        trace.value = texture_data.r;

        // If the sampled value exceeds the threshold, return early
        if (trace.value > u_raycast.threshold) 
        {
            return;   
        }
    }
}
