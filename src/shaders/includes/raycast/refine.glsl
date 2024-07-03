/**
 * refines the hit point by performing additional sampling steps.
 *
 * @param uniforms: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_value: output float where the refined value at the intersection will be stored.
 */
void refine(in uniforms_raycast uniforms, in uniforms_sampler u_sampler, in vec3 ray_step, inout vec3 hit_position, out float hit_value)
{
    // calculate the refined substep based on the number of refinements
    vec3 ray_substep = ray_step / uniforms.refinements;  

    // step back to refine the hit point
    hit_position -= ray_step;    
    hit_value = 0.0;

    // perform additional sampling steps to refine the hit point
    for (float i = 0.0; i < uniforms.refinements; i++) {
        
        // move position forward by substep
        hit_position += ray_substep;  
        
        // sample value again with refined position
        hit_value = sample_intensity_3d(u_sampler.volume, hit_position);  

        // if the sampled value exceeds the threshold, return early
        if (hit_value > uniforms.threshold) 
            return;   
    }
}
