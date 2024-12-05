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
float values[8];
for (int i = 0; i < 8; i++)
{
    vec3 sample_texels = trace.voxel_texels + u_volume.inv_dimensions * center_offsets[i];
    values[i] = texture(u_textures.taylormap, sample_texels).r;

    // correct edge cases due to trilinear interpolation and clamp to edge wrapping   
    values[i] /= exp2(sum(outside(vec3(0.0), vec3(1.0), sample_texels))); 
}

// compute gradient
trace.gradient = vec3(
    values[1] + values[5] + values[6] + values[7] - values[0] - values[3] - values[2] - values[4],
    values[2] + values[4] + values[6] + values[7] - values[0] - values[3] - values[1] - values[5],
    values[3] + values[4] + values[5] + values[7] - values[0] - values[2] - values[1] - values[6]
);

// update gradient
trace.gradient *= u_volume.inv_spacing * 0.25;
trace.gradient_direction = normalize(trace.gradient);
trace.gradient_magnitude = length(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);
trace.normal = -trace.gradient_direction;


