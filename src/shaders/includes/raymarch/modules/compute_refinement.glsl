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
void compute_refinement
(
    in uniforms_volume u_volume, 
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient, 
    in uniforms_sampler u_sampler, 
    in parameters_ray ray,
    inout parameters_trace trace
)
{
    // Step back to refine the hit point
    trace.position -= ray.direction * trace.spacing;
    trace.depth -= trace.spacing;

    // Calculate the refined substep based on the number of refinements
    float subspacing = trace.spacing / float(u_raycast.refinements + 1);  
      
    // Perform additional sampling steps to refine the hit point
    for (int i = 0; i <= u_raycast.refinements; i++) 
    {
        // Move position forward by substep
        trace.position += ray.direction * subspacing;  
        trace.depth += subspacing;
        trace.i_step++;
        
       // Sample the intensity of the volume at the current ray position
        trace.texel = trace.position * u_volume.inv_size;
        trace.value = texture(u_sampler.volume, trace.texel).r;

        // Extract gradient and value from texture data
        vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
        trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
        trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
        trace.gradient = trace.normal * trace.steepness;

        // If the sampled value exceeds the threshold, return early
        if (trace.value > u_raycast.threshold) 
        {
            return;   
        }
    }
}
