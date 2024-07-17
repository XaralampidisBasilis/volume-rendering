/**
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_volume: struct containing volume-related uniforms.
 * @param u_occupancy: struct containing occupancy-related uniforms.
 * @param ray_start: starting point of the ray.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @param hit_position: output vec3 where the position of the intersection will be stored.
 * @param hit_intensity: output float where the intensity at the intersection will be stored.
 * @return bool: returns true if an intersection is found above the threshold, false otherwise.
 */
bool marching_no_skip
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in ivec2 step_bounds,
    in vec3 ray_step,
    in vec3 ray_position,
    out vec3 hit_position,
    out float hit_sample,
    out float hit_depth
) 
{ 
    // raymarch loop to traverse through the volume
    float count = 0.0;
    float MAX_COUNT = 1.73205080757 / length(ray_step); // sqrt(3) / length(ray_step)

    for (int n_step = step_bounds.x; n_step < step_bounds.y && count < MAX_COUNT; n_step++, ray_position += ray_step) 
    {
        // sample the intensity of the volume at the current 'hit_position'.
        hit_sample = sample_intensity_3d(u_sampler.volume, ray_position);

        // if the sampled intensity exceeds the threshold, a hit is detected.
        if (hit_sample > u_raycast.threshold) 
        {
            hit_position = ray_position;
            refine_intersection(u_raycast, u_sampler, ray_step, hit_position, hit_sample); // Seems to decrease frame rate
            hit_depth = compute_frag_depth(u_volume, ray_position);
            return true;
        }

        count++;
    }   

    hit_position = vec3(1.0/0.0);
    hit_sample = 0.0;
    hit_depth = 1.0;
    return false;
}