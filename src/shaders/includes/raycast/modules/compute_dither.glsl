/**
 * applies dithering to the initial distance to avoid artifacts. 
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @return vec3: returns the dithered intensity value in [0, 1] range.
 */
float compute_dither(in uniforms_raycast u_raycast, in uniforms_sampler u_sampler, in vec3 ray_normal, in vec2 ray_bounds)
{
    // calculate the end position of the ray
    vec3 ray_end = ray_normal * ray_bounds.y;

    // compute a hash value based on the end position transformed by the matrix
    vec4 hash = v_projection_model_view_matrix * vec4(ray_end, 0.0);

    // sample intensity from the noisemap texture and apply the dithering factor
    float dither_intensity = sample_intensity_2d(u_sampler.noise, 1000.0 * hash.xy);    
    dither_intensity *= u_raycast.dithering;

    // return dithering step
    return dither_intensity; // in [0, 1]
}
