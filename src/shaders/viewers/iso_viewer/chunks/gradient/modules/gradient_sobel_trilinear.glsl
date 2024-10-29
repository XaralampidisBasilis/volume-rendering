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
vec3 texel_step = u_volume.inv_dimensions * 0.5;
float sample_value[8];
vec3 sample_texel;

vec3 box_min = 0.0 - texel_step * 0.5;
vec3 box_max = 1.0 - box_min;
vec3 is_outside;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++)
{
    sample_texel = trace.voxel_texture_coords + texel_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;

    // correct edge cases due to trillinear interpolation and clamp to edge wrapping   
    is_outside = outside(box_min, box_max, sample_texel);
    sample_value[i] /= exp2(sum(is_outside)); 
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
trace.gradient.x = sample_value[4] + sample_value[5] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[2] - sample_value[3];
trace.gradient.y = sample_value[2] + sample_value[3] + sample_value[6] + sample_value[7] - sample_value[0] - sample_value[1] - sample_value[4] - sample_value[5];
trace.gradient.z = sample_value[1] + sample_value[3] + sample_value[5] + sample_value[7] - sample_value[0] - sample_value[2] - sample_value[4] - sample_value[6];
trace.gradient *= u_volume.inv_spacing * 0.5; // // adjust gradient to physical space 
trace.gradient *= 8.0; // get integer kernel values from trilinear sampling
trace.gradient /= 16.0; // normalize the kernel values

trace.gradient_magnitude = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative_1st = dot(trace.gradient, ray.step_direction);


