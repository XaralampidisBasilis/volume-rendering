/**
 * Applies dithering to the initial distance to avoid artifacts.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param u_sampler: Struct containing sampler-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return float: Returns the dithered intensity value in the [0, 1] range.
 */
float dither_texture
(
        in sampler2D noisemap, 
        in vec3 volume_size, 
        in vec3 ray_direction,
        in vec2 ray_bounds
)
{
    // Calculate the end position of the ray.
    vec3 end_position = ray_direction * ray_bounds.y;

    // Compute a position value based on the end position transformed by the matrix.
    vec4 position = v_projection_model_view_matrix * vec4(end_position * volume_size, 1.0);

    // Perform perspective division to get NDC space.
    position /= position.w; 
    
    // Calculate NDC position in the range [0, 1].
    position = (position + 1.0) * 0.5; 

    // Subdivide the screen into multiple tilings.
    position *= 1000.0; 

    // Sample the noise map texture at xy coordinates.
    float dither_intensity = texture(noisemap, position.xy).r;    

    // Return the dithered intensity value in the [0, 1] range.
    return dither_intensity; 
}
