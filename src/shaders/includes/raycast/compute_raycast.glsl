#include ./modules/compute_bounds.glsl;
#include ./modules/compute_dithering.glsl;
#include ./steps/compute_step.glsl;
#include ../marching/compute_marching.glsl;

/**
 * performs raycasting in a 3d texture to find the depth and intensity of an intersection.
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
bool compute_raycast
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in uniforms_sampler u_sampler,
    in vec3 ray_start, 
    in vec3 ray_normal, 
    out vec3 hit_position,
    out float hit_sample,
    out float hit_depth
) {    
    // compute the intersection bounds of a ray with occypancy axis-aligned bounding box.
    vec2 ray_bounds = compute_bounds(u_occupancy, ray_start, ray_normal); // debug gl_FragColor = vec4(vec3((ray_bounds.y-ray_bounds.x) / 1.732), 1.0);  

    // compute the ray step vector based on the raycast and volume parameters
    vec3 ray_step = compute_step(u_raycast, u_volume, ray_normal, ray_bounds); 

    // apply dithering to the initial distance to avoid artifacts
    float ray_dithering = compute_dithering(u_raycast, u_sampler, ray_normal, ray_bounds); // debug gl_FragColor = vec4(vec3(ray_dither), 1.0);  

    // initialize the starting position along the ray
    vec3 ray_position = ray_start + ray_normal * ray_bounds.x  - ray_step * ray_dithering;
    
    // compute the ray step delta and step bounds
    ivec2 step_bounds = ivec2(ray_bounds / length(ray_step)); // debug gl_FragColor = vec4((step_bounds.y-step_bounds.x)*ray_delta/1.732, 1.0);  

    // raycasting loop to traverse through the volume
    return compute_marching(u_raycast, u_volume, u_occupancy, u_sampler, step_bounds, ray_step, ray_position, hit_position, hit_sample, hit_depth);
}
