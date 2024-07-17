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
    in uniforms_raycast u_raycast, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_step, 
    in int skip_steps, 
    inout vec3 ray_position, 
    out float ray_sample
) {

    vec3 ray_position_0 = ray_position;
    
    for (int i_step = 0; i_step < skip_steps; i_step++, ray_position += ray_step) {

        // sample the intensity of the volume at the current 'hit_position'.
        ray_sample = sample_intensity_3d(u_sampler.volume, ray_position);

        // if the sampled intensity exceeds the threshold, a hit is detected.
        if (ray_sample > u_raycast.threshold) 
            return true;
    }

    ray_position = ray_position_0;
    ray_sample = 0;
    return false;
}
