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
    in vec3 ray_origin,
    in float ray_min_distance,
    in float ray_max_distance
)
{
    // Calculate the end position of the ray.
    float mean_distance = mean(ray_min_distance, ray_max_distance);
    vec3 sample_position = ray_origin + ray_direction * mean_distance;

    // Compute the ray end position in world coordinates.
    sample_position = vec3(v_model_view_matrix * vec4(sample_position, 1.0));

    // Generate a random number based on position
    float dithering = random(sample_position); 

    // Return the dithered intensity value in the [0, 1] range.
    return dithering; 
}
