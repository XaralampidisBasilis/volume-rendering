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
const vec2 center_offset = vec2(-0.5, 0.5);
const vec3 center_offsets[8] = vec3[8]
(
    center_offset.xxx, center_offset.yxx, 
    center_offset.xyx, center_offset.xxy, 
    center_offset.xyy, center_offset.yxy,
    center_offset.yyx, center_offset.yyy 
);

float samples[8];
vec3 uvw = u_volume.inv_dimensions * voxel.entry_position;

for (int i = 0; i < 8; i++)
{
    vec3 offset = u_volume.inv_dimensions * center_offsets[i];
    samples[i] = texture(u_textures.binary_map, uvw + offset).r;
}

vec3 forward = vec3(
    samples[1] + samples[5] + samples[6] + samples[7], // x-axis
    samples[2] + samples[4] + samples[6] + samples[7], // y-axis
    samples[3] + samples[4] + samples[5] + samples[7]  // z-axis
);

vec3 backward = vec3(
    samples[0] + samples[3] + samples[2] + samples[4], // x-axis
    samples[0] + samples[3] + samples[1] + samples[5], // y-axis
    samples[0] + samples[2] + samples[1] + samples[6]  // z-axis
);

// Compute gradient
trace.gradient = (forward - backward) / (u_volume.spacing * 4.0);

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 8;
#endif
