#define epsilon 0.01

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
bool traverse( 
    in raycast_uniforms u_raycast, 
    in sampler3D sampler_volume, 
    in vec3 ray_step, 
    in float num_steps, 
    inout vec3 ray_position, 
    out float ray_intensity
) {
    
    vec3 ray_start = ray_position;

    // iterate through the volume, stepping by 'ray_step', up to 'skip_steps' times.
    for (float n_step = 0.0; n_step < num_steps + epsilon; n_step++, ray_position += ray_step) {

        // sample the intensity of the volume at the current 'hit_position'.
        ray_intensity = sample_intensity_3d(sampler_volume, ray_position);

        // if the sampled intensity exceeds the threshold, a hit is detected.
        if (ray_intensity > u_raycast.threshold) 
        {
            refine(u_raycast, sampler_volume, ray_step, ray_position, ray_intensity);
            return true;
        }

    }

    // no hit was detected within the given number of steps.
    ray_position = ray_start;
    return false;
}
