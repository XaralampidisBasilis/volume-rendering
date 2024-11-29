
// DITHERING GENERATIVE
/**
 * Generates dithering based on the world-space position of the ray's mean distance
 * This is used to add randomness to the ray's sampling step size for smoother results.
 *
 * @input ray.start_distance   : minimum distance along the ray (float)
 * @input ray.end_distance   : maximum distance along the ray (float)
 * @input ray.camera_position         : the starting point of the ray (vec3)
 * @input ray.step_direction      : the normalized direction vector of the ray (vec3)
 * @input v_model_view_matrix: the model-view matrix for transforming from model to world coordinates (mat4)
 * @input ray.max_step_distance    : the maximum spacing for raymarching steps (float)
 *
 * @output ray.dithering : a small random offset in the range [0, ray.max_step_distance] subtracted from the ray's start distance (float)
 */

// Compute seed position position in homogenous world coordinates
float seed_distance = mean(ray.box_min_distance, ray.box_max_distance);
vec4 seed_position = vec4(ray.camera_position + ray.step_direction * seed_distance, 1.0);
seed_position = v_model_view_matrix * seed_position;

// update ray start based on random step distance
ray.rand_distance = random(seed_position.xyz) * ray.step_distance;
ray.start_distance -= ray.rand_distance;
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance;
ray.span_distance = ray.end_distance - ray.start_distance;
