/**
 * refines the hit point by performing additional sampling steps.
 *
 * @param uniforms: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_value: output float where the refined value at the intersection will be stored.
 */
void refine(in uniforms_raycast u_raycast, in uniforms_sampler u_sampler, in vec3 ray_step, inout vec3 ray_position, out float ray_sample)
{
    // calculate the refined substep based on the number of refinements
    vec3 ray_substep = ray_step / float(u_raycast.refinements + 1);  

    // step back to refine the hit point
    ray_position -= ray_step;    
    ray_sample = 0.0;

    // perform additional sampling steps to refine the hit point
    for (int substep = 0; substep <= u_raycast.refinements; substep++) {
        
        // move position forward by substep
        ray_position += ray_substep;  
        
        // sample value again with refined position
        ray_sample = sample_intensity_3d(u_sampler.volume, ray_position);  

        // if the sampled value exceeds the threshold, return early
        if (ray_sample > u_raycast.threshold) return;   
    }
}
