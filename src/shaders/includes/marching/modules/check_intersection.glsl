/**
 * performs a raycasting operation in a 3d volume texture to determine if a block of voxels is hit by the ray.
 *
 * @param u_raycast: struct containing raycast-related uniforms, including the threshold.
 * @param sampler_volume: 3d volume texture to sample from.
 * @param ray_step: step vector representing the ray's increment direction and distance per step.
 * @param skip_steps: number of steps to skip before considering a voxel as hit.
 * @param hit_position: inout vec3 where the current position of the ray in the 3d volume is modified in-place as the ray steps through the volume.
 * @param hit_intensity: output float where the intensity of the voxel where the ray hits will be stored, if a hit occurs.
 * @return bool: returns true if an intersection is found above the threshold, false otherwise.
 */
bool check_intersection
( 
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_sampler u_sampler, 
    in uniforms_volume u_volume, 
    in vec3 ray_step, 
    in int skip_steps, 
    in vec3 ray_position, 
    out vec3 hit_position,
    out vec3 hit_normal,
    out float hit_sample,
    out float hit_depth
) 
{
    hit_position = ray_position;
    float hit_gradient = 0.0;
    
    for (int i_step = 0; i_step < skip_steps; i_step++, hit_position += ray_step) {

        // sample the intensity of the volume at the current 'hit_position'.
        hit_sample = sample_intensity_3d(u_sampler.volume, hit_position);

        // if the sampled intensity exceeds the threshold, a hit is detected.
        if (hit_sample > u_raycast.threshold) 
        {
            // refine the hit position
            refine_intersection(u_raycast, u_sampler, ray_step, hit_position, hit_sample);

            // compute the gradient at the current hit position
            hit_normal = compute_gradient(u_gradient, u_volume, u_sampler, hit_position, hit_sample, hit_gradient);     

            // check if the gradient magnitude exceeds the threshold
            if (hit_gradient > u_gradient.threshold)
            {
                hit_depth = compute_frag_depth(u_volume, hit_position);                
                return true;
            }
        }
    }

    hit_position = vec3(1.0/0.0); 
    hit_normal = vec3(0.0);
    hit_sample = 0.0;
    hit_depth = 1.0;    

    return false;
}
