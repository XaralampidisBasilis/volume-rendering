
// DITHERING_TEXTURE
/**
 * Generates dithering using a noise texture based on the ray's start position in screen space.
 * This adds randomness to the ray's sampling step size for smoother rendering.
 * This function transforms the ray's minimum distance position into normalized device coordinates (NDC),
 * scales the NDC position, and samples a noise texture to generate dithering.
 *
 * @input ray.origin                    : the starting point of the ray
 * @input ray.direction                 : the direction vector of the ray (normalized)
 * @input ray.min_distance              : minimum distance along the ray
 * @input v_projection_model_view_matrix: the matrix for transforming from model to NDC space
 * @input ray.max_spacing               : the maximum spacing for raymarching steps
 * @input u_sampler.noisemap            : 2D noise texture sampler
 *
 * @output ray.dithering : a small random offset in the range [0, ray.max_spacing] subtracted from the ray's start distance
 */

// calculate the minimum distance position along the ray.
vec3 ray_min_position = ray.origin + ray.direction * ray.min_distance;

// compute the position value by transforming it with the projection-model-view matrix.
vec4 seed_position = v_projection_model_view_matrix * vec4(ray_min_position, 1.0);

// perform perspective division to convert to NDC space.
seed_position /= seed_position.w;

// calculate NDC position in the range [0, 1].
seed_position = (seed_position + 1.0) * 0.5;

// subdivide the screen into multiple tilings for noise texture sampling.
seed_position *= 1000.0;

// sample the noise map texture at the xy coordinates to generate dithering.
ray.dithering = texture(u_sampler.noisemap, seed_position.xy).r;
ray.dithering = clamp(ray.dithering, 0.0 + MILLI_TOL, 1.0 - MILLI_TOL);
ray.dithering *= ray.spacing;
