/**
 * applies dithering to the initial distance to avoid artifacts. 
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @return vec3: returns the dithered intensity value in [0, 1] range.
 */
vec3 dither(in raycast_uniforms u_raycast, in vec3 ray_step, in vec2 step_bounds)
{
    // calculate the end position of the ray
    vec3 ray_end = ray_step * step_bounds.y;

    // compute a hash value based on the end position transformed by the matrix
    vec4 hash = v_projection_model_view_matrix * vec4(ray_end, 0.0);

    // sample intensity from the noisemap texture and apply the dithering factor
    float dither_intensity = sample_intensity_2d(u_sampler_noise, 1000.0 * hash.xy);    
    dither_intensity *= u_raycast.dither;

    // return dithering step
    return dither_intensity * ray_step;
}
