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
bool marching_skip
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in ivec2 step_bounds,
    in vec3 ray_step,
    inout vec3 ray_position,
    out float ray_sample,
    out float ray_depth
) 
{ 
    // initialize state vaiables
    int skip_steps[3] = int[3](0, 0, 0);
    int current_level = 0;
    int next_level = 0;

    // raymarch loop to traverse through the volume
    float count = 0.0;
    float MAX_COUNT = 1.73205080757 / length(ray_step); // for some reason some rays do not terminate. Need to find why

    for (int n_step = step_bounds.x; n_step < step_bounds.y && count < MAX_COUNT; ) 
    {
        // traverse space if block is occupied
        bool occupied = skip_space(u_occupancy, u_volume, u_sampler, ray_position, ray_step, skip_steps, current_level, next_level);
        if (occupied) 
        {            
            // terminate marching if ray  hit
            bool has_hit = traverse_space(u_raycast, u_sampler, ray_step, skip_steps[current_level], ray_position, ray_sample);
            if (has_hit) 
            {
                gl_FragColor = vec4(vec3(count/MAX_COUNT), 1.0); // for debug
                ray_depth = compute_frag_depth(u_volume, ray_position);
                return true;
            }
        }

        ray_position += ray_step * float(skip_steps[current_level]);
        n_step += skip_steps[current_level];

        count++;
    }   

    gl_FragColor = vec4(vec3(count/MAX_COUNT), 1.0); // for debug
    ray_depth = 1.0;
    ray_sample = 0.0;
    return false;
}