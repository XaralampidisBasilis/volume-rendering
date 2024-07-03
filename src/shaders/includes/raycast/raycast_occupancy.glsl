#include ../raycast/stride/stride.glsl;
#include ../raycast/bounds.glsl;
#include ../raycast/dither.glsl;
#include ../raycast/refine.glsl;
#include ../raycast/traverse.glsl;
#include ../occupancy/mono_resolution.glsl;

/**
 * performs raycasting in a 3d texture using occlussion blocks ray skipping
 *
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
bool raycast_occupancy
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in vec3 ray_start, 
    in vec3 ray_normal, 
    out vec3 ray_position, 
    out float ray_intensity
) {    
    // compute the intersection bounds of a ray with occupancy axis-aligned bounding box.
    vec2 ray_bounds = bounds(u_occupancy, ray_start, ray_normal); // gl_FragColor = vec4(vec3((ray_bounds.y-ray_bounds.x) / 1.732), 1.0); 

    // compute the ray step vector based on the raycast and volume parameters
    vec3 ray_step = stride(u_raycast, u_volume, ray_normal, ray_bounds); // gl_FragColor = vec4((ray_normal * 0.5) + 0.5, 1.0); 
    
    // compute the ray step delta and step bounds
    float ray_delta = length(ray_step); 
    vec2 step_bounds = ray_bounds / ray_delta; // gl_FragColor = vec4(vec3(float(step_bounds.y-step_bounds.x) / (1.732/ray_delta)), 1.0); 

    // apply dithering to the initial distance to avoid artifacts
    vec3 dither_step = dither(u_raycast, u_sampler, ray_step, step_bounds); // gl_FragColor = vec4(-normalize(dither_step), 1.0); 

    // initialize the starting position along the ray
    ray_position = ray_start + ray_step * step_bounds.x - dither_step; // gl_FragColor = vec4(hit_position, 1.0); 
    
    // raycasting loop to traverse through the volume
    vec2 traverse_steps = vec2(0.0);
    float exit_steps = 0.0;

    for (float n_step = step_bounds.x; n_step < step_bounds.y; n_step++, ray_position += ray_step) {

        // check if the current block is occupied
        bool occupied = mono_resolution (u_occupancy, u_volume, u_sampler, ray_position, ray_step, traverse_steps, exit_steps);
        if (occupied) {
                        
            // perform raycasting in the occupied block 
            bool hit = traverse(u_raycast, u_sampler, ray_step, traverse_steps, ray_position, ray_intensity);
            if (hit) 
                return true;
        } 

        // skip the specified number of steps and go to the end of the block
        ray_position += ray_step * exit_steps;
        n_step += exit_steps;
    }   

    // if no intersection is found, set hit_intensity to 0
    ray_intensity = 0.0;
    return false; // no intersection
}
