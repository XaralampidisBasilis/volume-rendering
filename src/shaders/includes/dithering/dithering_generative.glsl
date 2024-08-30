/**
 * Applies dithering to the initial distance to avoid artifacts.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return float: Returns the dithered intensity value in the [0, 1] range.
 */
float dithering_generative
(
    in vec3 ray_direction,
    in vec2 ray_bounds
)
{
    // Calculate the end position of the ray.
    vec3 end_position = ray_direction * ray_bounds.y;

    // Compute the ray end position in world coordinates.
    end_position = vec3(v_model_view_matrix * vec4(end_position, 1.0));

    // Generate a random number based on position
    float dither_intensity = random(end_position); 

    // Return the dithered intensity value in the [0, 1] range.
    return dither_intensity; 
}
