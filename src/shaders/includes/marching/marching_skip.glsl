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
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in ivec2 step_bounds,
    in vec3 ray_step,
    in vec3 ray_position,
    out vec3 hit_position,
    out vec3 hit_normal,
    out float hit_sample,
    out float hit_depth
) 
{ 
    // initialize state vaiables
    int skip_steps[3] = int[3](0, 0, 0);
    int current_level = 0;
    int next_level = 0;

    // raymarch loop to traverse through the volume
    float hit_gradient = 0.0;
    float count = 0.0;
    float MAX_COUNT = 1.73205080757 / length(ray_step); // for some reason some rays do not terminate. Need to find why

    for (int i_step = step_bounds.x; i_step < step_bounds.y && count < MAX_COUNT; count++) 
    {
        // traverse space if block is occupied
        bool occupied = check_occupancy(u_occupancy, u_volume, u_sampler, ray_position, ray_step, skip_steps, current_level, next_level);
        if (occupied) 
        {            
            // terminate marching if ray  hit
            bool intersected = check_intersection(u_raycast, u_sampler, ray_step, skip_steps[current_level], ray_position, hit_position, hit_sample);
            if (intersected) 
            {
                // compute the gradient at the current hit position
                hit_normal = compute_gradient(u_gradient, u_volume, u_sampler, hit_position, hit_sample, hit_gradient);     

                // check if the gradient magnitude exceeds the threshold
                if (hit_gradient > u_gradient.threshold)
                {
                    refine_intersection(u_raycast, u_sampler, ray_step, hit_position, hit_sample);

                    // recompute the gradient after refining the intersection
                    hit_normal = compute_gradient(u_gradient, u_volume, u_sampler, hit_position, hit_sample, hit_gradient);     
                    hit_depth = compute_frag_depth(u_volume, hit_position);                   
                    
                    return true;
                }
            }
        }
        
        // update ray and skip space
        i_step += skip_steps[current_level];
        ray_position += ray_step * float(skip_steps[current_level]);
        current_level = next_level;
    }   

    // no intersection found
    hit_position = vec3(+1.0/+0.0); // set to infinity
    hit_normal = vec3(0.0);
    hit_sample = 0.0;
    hit_depth = 1.0;
    return false;
}