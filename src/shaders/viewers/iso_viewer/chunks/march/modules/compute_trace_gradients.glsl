// gradient_sobel8

/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using trilinear interpolation sobel operator and smoothing
 * https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */

// Sample neighbors
float value[8];
vec3 base_texels = trace.voxel_texels - u_volume.inv_dimensions * 0.5;
for (int i = 0; i < 8; i++)
{
    value[i] = textureOffset(u_textures.volume, base_texels, base_offsets[i]).r;
}

// Compute gradient
trace.gradient = vec3(
    value[4] + value[5] + value[6] + value[7] - value[0] - value[1] - value[2] - value[3],
    value[2] + value[3] + value[6] + value[7] - value[0] - value[1] - value[4] - value[5],
    value[1] + value[3] + value[5] + value[7] - value[0] - value[2] - value[4] - value[6]
);

// Update gradient
trace.gradient *= u_volume.inv_spacing * 0.25;
trace.gradient_direction = normalize(trace.gradient);
trace.gradient_magnitude = length(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;


