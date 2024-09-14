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

// define offsets for 8 neighboring points
const vec2 k = vec2(-1.0, +1.0);
const vec3 sample_offset[8] = vec3[8]
(
    k.xxx, k.xxy, 
    k.xyx, k.xyy, 
    k.yxx, k.yxy,
    k.yyx, k.yyy 
);

// Sample values at the neighboring points
float sample_value[8];
vec3 voxel_step = u_volume.inv_dimensions;
vec3 voxel_texel = (trace.coords + 0.5) * voxel_step;
vec3 sub_step = voxel_step * 0.5;
vec3 sample_texel;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++)
{
    sample_texel = voxel_texel + sub_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;
    sample_value[i] /= exp2(sum(outside(sub_step, 1.0 - sub_step, sample_texel))); // correct edge cases due to trillinear interpolation and clamp to edge wrapping   
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
trace.gradient.x = sample_value[4] + sample_value[5] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[2] - sample_value[3];
trace.gradient.y = sample_value[2] + sample_value[3] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[4] - sample_value[5];
trace.gradient.z = sample_value[1] + sample_value[3] + sample_value[5] + sample_value[7] - sample_value[0] - sample_value[2] - sample_value[4] - sample_value[6];
trace.gradient *= u_volume.inv_spacing * 0.5; // // adjust gradient to physical space 
trace.gradient *= 8.0; // get integer kernel values from trilinear sampling
trace.gradient /= 16.0; // normalize the kernel values

trace.gradient_norm = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);


