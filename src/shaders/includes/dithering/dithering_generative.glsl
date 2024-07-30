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
    in uniforms_volume u_volume, 
    in parameters_ray ray
)
{
    // Calculate the end position of the ray.
    vec3 ray_end = ray.direction * ray.bounds.y;

    // Compute the ray end position in world coordinates.
    ray_end = vec3(v_model_view_matrix * vec4(ray_end * u_volume.size, 1.0));

    // Generate a random number based on position
    float dither_intensity = random(ray_end); 

    // Return the dithered intensity value in the [0, 1] range.
    return dither_intensity; 
}
