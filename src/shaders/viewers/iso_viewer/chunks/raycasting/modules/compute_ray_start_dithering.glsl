
// DITHERING GENERATIVE
/**
 * Generates dithering based on the world-space position of the ray's mean distance
 * This is used to add randomness to the ray's sampling step size for smoother results.
 *
 * @input ray.start_distance   : minimum distance along the ray (float)
 * @input ray.end_distance   : maximum distance along the ray (float)
 * @input ray.origin_position         : the starting point of the ray (vec3)
 * @input ray.step_direction      : the normalized direction vector of the ray (vec3)
 * @input v_model_view_matrix: the model-view matrix for transforming from model to world coordinates (mat4)
 * @input ray.max_step_distance    : the maximum spacing for raymarching steps (float)
 *
 * @output ray.dithering : a small random offset in the range [0, ray.max_step_distance] subtracted from the ray's start distance (float)
 */

// calculate the mean distance along the ray.
float ray_mean_distance = mean(ray.box_min_distance, ray.box_max_distance);

// calculate the sample position based on the mean distance.
vec3 seed_position = ray.origin_position + ray.step_direction * ray_mean_distance;

// transform the sample position to world coordinates.
seed_position = vec3(v_model_view_matrix * vec4(seed_position, 1.0));

// generate a random number based on the world-space position and apply dithering.
ray.rand_distance = random(seed_position);
ray.rand_distance *= ray.max_step_distance;

// update ray
ray.start_distance -= ray.rand_distance;
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
ray.span_distance = ray.end_distance - ray.start_distance;
ray.span_distance = max(ray.span_distance, 0.0);
