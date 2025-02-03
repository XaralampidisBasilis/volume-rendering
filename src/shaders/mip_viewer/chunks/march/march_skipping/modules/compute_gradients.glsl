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
float intensities[8];
for (int i = 0; i < 8; i++)
{
    vec3 uvw_offset = trace.uvw + u_intensity_map.inv_dimensions * center_offsets[i];
    intensities[i] = texture(u_textures.intensity_map, uvw_offset).r;
}

// Precompute summed groups of intensities for better clarity
vec3 forward_intensity = vec3(
    intensities[1] + intensities[5] + intensities[6] + intensities[7], // x-axis
    intensities[2] + intensities[4] + intensities[6] + intensities[7], // y-axis
    intensities[3] + intensities[4] + intensities[5] + intensities[7]  // z-axis
);

vec3 backward_intensity = vec3(
    intensities[0] + intensities[3] + intensities[2] + intensities[4], // x-axis
    intensities[0] + intensities[3] + intensities[1] + intensities[5], // y-axis
    intensities[0] + intensities[2] + intensities[1] + intensities[6]  // z-axis
);

// Compute gradient
trace.gradient = (forward_intensity - backward_intensity) / (u_intensity_map.spacing * 4.0);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 8;
#endif
