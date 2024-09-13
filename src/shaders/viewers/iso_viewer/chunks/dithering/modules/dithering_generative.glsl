/**
 * Applies dithering to the initial distance to avoid artifacts.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return float: Returns the dithered intensity value in the [0, 1] range.
 */

// Calculate the end position of the ray.
float mean_distance = mean(ray.min_distance, ray.max_distance);
vec3 sample_position = ray.origin + ray.direction * mean_distance;

// Compute the ray end position in world coordinates.
sample_position = vec3(v_model_view_matrix * vec4(sample_position, 1.0));

// Generate a random number based on position
ray.dithering = random(sample_position) * ray.max_spacing; 


