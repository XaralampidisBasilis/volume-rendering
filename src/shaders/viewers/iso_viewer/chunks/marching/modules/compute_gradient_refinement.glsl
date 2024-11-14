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
vec3 sample_texture_coords;

vec3 texture_min = vec3(0.0) - u_volume.inv_dimensions * 0.25;
vec3 texture_max = vec3(1.0) + u_volume.inv_dimensions * 0.25;

for (int i = 0; i < 8; i++)
{
    sample_texture_coords = trace.voxel_texture_coords + u_volume.inv_dimensions * centered_offsets[i];
    sample_value[i] = texture(u_textures.volume, sample_texture_coords).r;

    // correct edge cases due to trillinear interpolation and clamp to edge wrapping   
    sample_value[i] /= exp2(sum(outside(texture_min, texture_max, sample_texture_coords))); 
}

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


