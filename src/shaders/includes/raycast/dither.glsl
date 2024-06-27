#include ../../utils/sample_intensity.glsl

varying mat4 v_projection_model_view_matrix; // from vertex shader projectionMatrix * modelMatrix * viewMatrix

/**
 * applies dithering to the initial distance to avoid artifacts. 
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param ray_normal: direction vector of the ray (should be normalized).
 * @param ray_bounds: vec2 containing the start and end distances for raycasting.
 * @return float: returns the dithered intensity value in [0, 1] range.
 */
float dither(in raycast_uniforms u_raycast, in vec3 ray_normal, in vec2 ray_bounds)
{
    // calculate the end position of the ray
    vec3 ray_end = ray_normal * ray_bounds.y;

    // compute a hash value based on the end position transformed by the matrix
    vec4 hash = v_projection_model_view_matrix * vec4(ray_end, 0.0);

    // sample intensity from the noisemap texture and apply the dithering factor
    return sample_intensity(u_raycast.noisemap, 1000.0 * hash.xy) * u_raycast.dither;    
}
