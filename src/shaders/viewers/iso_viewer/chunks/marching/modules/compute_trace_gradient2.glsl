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

// Sample values at the neighboring points
float sample_value[8];
vec3 base_coords = trace.voxel_texture_coords - u_volume.inv_dimensions * 0.5;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++)
{
    sample_value[i] = textureOffset(u_textures.volume, base_coords, base_offsets[i]).r;
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
trace.gradient = vec3(
    sample_value[4] + sample_value[5] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[2] - sample_value[3],
    sample_value[2] + sample_value[3] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[4] - sample_value[5],
    sample_value[1] + sample_value[3] + sample_value[5] + sample_value[7] - sample_value[0] - sample_value[2] - sample_value[4] - sample_value[6]
);

trace.gradient *= u_volume.inv_spacing * 0.25;
trace.gradient_direction = normalize(trace.gradient);
trace.gradient_magnitude = length(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;


