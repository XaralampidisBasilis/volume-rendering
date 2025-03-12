/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using trilinear interpolation sobel operator and smoothing
 * https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */

// Sample neighbors
const vec3 center_offset = vec3(-0.5, 0.0, 0.5);
const vec3 center_offsets[6] = vec3[6]
(
    center_offset.xyy, center_offset.zyy, 
    center_offset.yxy, center_offset.yzy, 
    center_offset.yyx, center_offset.yyz
);

float samples[6];
for (int i = 0; i < 6; i++)
{
    vec3 offset = center_offsets[i] * u_volume.inv_dimensions;
    samples[i] = texture(u_textures.binary_map, trace.position + offset).r;
}

// Gather samples
vec3 forward = vec3(samples[1], samples[3], samples[5]);
vec3 backward = vec3(samples[0], samples[2], samples[4]);

// Compute gradient
trace.gradient = (forward - backward) / u_volume.spacing;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 6;
#endif
