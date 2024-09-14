/**
 * Applies dithering to the initial distance to avoid artifacts.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param u_sampler: Struct containing sampler-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return float: Returns the dithered intensity value in the [0, 1] range.
 */
float dithering_texture
(
        in sampler2D noisemap, 
        in vec3 ray_direction,
        in vec3 ray_origin,
        in float ray_min_distance
)
{
    // Calculate the end position of the ray.
    vec3 ray_position = ray_origin + ray_direction * ray_min_distance;

    // Compute a position value based on the end position transformed by the matrix.
    vec4 sample_position = v_projection_model_view_matrix * vec4(ray_position, 1.0);

    // Perform perspective division to get NDC space.
    sample_position /= sample_position.w;
    
    // Calculate NDC position in the range [0, 1].
    sample_position = (sample_position + 1.0) * 0.5; 

    // Subdivide the screen into multiple tilings.
    sample_position *= 1000.0; 

    // Sample the noise map texture at xy coordinates.
    float dithering = texture(noisemap, sample_position.xy).r;    

    // Return the dithered intensity value in the [0, 1] range.
    return dithering; 
}
