
// DITHERING GENERATIVE
/**
 * Generates dithering based on the world-space position of the ray's mean distance
 * This is used to add randomness to the ray's sampling step size for smoother results.
 *
 * @input ray.min_distance   : minimum distance along the ray (float)
 * @input ray.max_distance   : maximum distance along the ray (float)
 * @input ray.origin         : the starting point of the ray (vec3)
 * @input ray.direction      : the normalized direction vector of the ray (vec3)
 * @input v_model_view_matrix: the model-view matrix for transforming from model to world coordinates (mat4)
 * @input ray.max_spacing    : the maximum spacing for raymarching steps (float)
 *
 * @output ray.dithering : a small random offset in the range [0, ray.max_spacing] subtracted from the ray's start distance (float)
 */

// calculate the mean distance along the ray.
float ray_mean_distance = mean(ray.min_distance, ray.max_distance);

// calculate the sample position based on the mean distance.
vec3 seed_position = ray.origin + ray.direction * ray_mean_distance;

// transform the sample position to world coordinates.
seed_position = vec3(v_model_view_matrix * vec4(seed_position, 1.0));

// generate a random number based on the world-space position and apply dithering.
ray.dithering = random(seed_position);
ray.dithering = clamp(ray.dithering, 0.0 + EPSILON3, 1.0 - EPSILON3) ;
ray.dithering *= ray.min_spacing;
