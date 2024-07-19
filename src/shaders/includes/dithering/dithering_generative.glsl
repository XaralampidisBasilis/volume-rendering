/**
 * applies dithering to the initial distance to avoid artifacts. 
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @return vec3: returns the dithered intensity value in [0, 1] range.
 */
float dithering_random
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_normal, 
    in vec2 ray_bounds
)
{
    // calculate the end position of the ray
    vec3 ray_end = ray_normal * ray_bounds.y;

    // compute ray end position in world coordinates
    vec4 position = v_model_view_matrix * vec4(ray_end * u_volume.size, 1.0);
    float dither_intensity = random(position.xyz); 

    dither_intensity *= u_raycast.dithering;

    // return dithering step
    return dither_intensity; // in [0, 1]
}
