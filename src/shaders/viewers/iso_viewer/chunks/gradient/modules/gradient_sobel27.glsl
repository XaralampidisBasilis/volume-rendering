// gradient_sobel27

/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using trilinear interpolation sobel operator and smoothing
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */

// compute sobel 27 kernels 
const float[27] kernel_x = float[27]
(
     -1.0,   -2.0,   -1.0,
     -2.0,   -4.0,   -2.0,
     -1.0,   -2.0,   -1.0,
      0.0,   0.0,   0.0,
     0.0,   0.0,   0.0,
     0.0,   0.0,   0.0,
    +1.0,  +2.0,  +1.0,
    +2.0,  +4.0,  +2.0,
    +1.0,  +2.0,  +1.0
);
const float[27] kernel_y = float[27]
(
     -1.0,   -2.0,   -1.0,
      0.0,    0.0,    0.0,
     +1.0,   +2.0,   +1.0,
     -2.0,  -4.0,  -2.0,
     0.0,   0.0,   0.0,
    +2.0,  +4.0,  +2.0,
    -1.0,  -2.0,  -1.0,
     0.0,   0.0,   0.0,
    +1.0,  +2.0,  +1.0
);
const float[27] kernel_z = float[27]
(
     -1.0,    0.0,   +1.0,
     -2.0,    0.0,   +2.0,
     -1.0,    0.0,   +1.0,
     -2.0,   0.0,  +2.0,
    -4.0,   0.0,  +4.0,
    -2.0,   0.0,  +2.0,
    -1.0,   0.0,  +1.0,
    -2.0,   0.0,  +2.0,
    -1.0,   0.0,  +1.0
);

// Define offsets for the 26 neighboring sample and the center
const vec3 k = vec3(-1.0, 0.0, +1.0);
const vec3[27] sample_offset = vec3[27]
(
     k.xxx,   k.xxy,   k.xxz,  
     k.xyx,   k.xyy,   k.xyz,  
     k.xzx,   k.xzy,   k.xzz,
     k.yxx,  k.yxy,  k.yxz, 
    k.yyx,  k.yyy,  k.yyz,
    k.yzx,  k.yzy,  k.yzz,
    k.zxx,  k.zxy,  k.zxz, 
    k.zyx,  k.zyy,  k.zyz, 
    k.zzx,  k.zzy,  k.zzz
);

// Sample values at the neighboring points
vec3 voxel_step = u_volume.inv_dimensions;
float sample_value[27];
vec3 sample_texel;

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    sample_texel = trace.texel + voxel_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;
    sample_value[i] *= inside_box(EPSILON3, 1.0 - EPSILON3, sample_texel);
}
#pragma unroll_loop_end

// Calculate the gradient based on the sampled values using the Sobel operator
#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    trace.gradient.x += kernel_x[i] * sample_value[i];
    trace.gradient.y += kernel_y[i] * sample_value[i];
    trace.gradient.z += kernel_z[i] * sample_value[i];
}
#pragma unroll_loop_end
trace.gradient *= u_volume.inv_spacing * 0.5; // // adjust gradient to physical space 
trace.gradient /= 16.0; // normalize the kernel values

trace.gradient_norm = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);
