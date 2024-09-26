
// Compute prewitt 27 kernels for x,y,z directions
const float[27] kernel_x = float[27]
(
    -1.0,  -1.0,   -1.0,
    -1.0,  -1.0,   -1.0,
    -1.0,  -1.0,   -1.0,
    0.0,  0.0,   0.0,
    0.0,  0.0,   0.0,
    0.0,  0.0,   0.0,
    +1.0, +1.0,  +1.0,
    +1.0, +1.0,  +1.0,
    +1.0, +1.0,  +1.0
);
const float[27] kernel_y = float[27]
(
    -1.0,  -1.0,  -1.0,
    0.0,   0.0,   0.0,
    +1.0,  +1.0,  +1.0,
    -1.0, -1.0, -1.0,
    0.0,  0.0,  0.0,
    +1.0, +1.0, +1.0,
    -1.0, -1.0, -1.0,
    0.0,  0.0,  0.0,
    +1.0, +1.0, +1.0
);
const float[27] kernel_z = float[27]
(
    -1.0,   0.0,   +1.0,
    -1.0,   0.0,   +1.0,
    -1.0,   0.0,   +1.0,
    -1.0,  0.0,  +1.0,
    -1.0,  0.0,  +1.0,
    -1.0,  0.0,  +1.0,
    -1.0,  0.0,  +1.0,
    -1.0,  0.0,  +1.0,
    -1.0,  0.0,  +1.0
);

// Define offsets for the 26 neighboring samples
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

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions;

// Sample values at the neighboring points
float sample_value[27];
vec3 sample_texel;

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    sample_texel = voxel_texel + texel_step * sample_offset[i];
    sample_value[i] = textureLod(volume_data, sample_texel, 0.0).r;
    sample_value[i] *= inside_box(0.0, 1.0, sample_texel);
}
#pragma unroll_loop_end

// Calculate the gradient based on the sampled values using the Sobel operator
vec3 gradient = vec3(0.0);

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    gradient.x += kernel_x[i] * sample_value[i];
    gradient.y += kernel_y[i] * sample_value[i];
    gradient.z += kernel_z[i] * sample_value[i];
}
#pragma unroll_loop_end

// Normalize the kernel values
gradient /= 9.0;
  
// Adjust gradient to physical space 
gradient *= 0.5 * volume_inv_spacing;

// Combine results
gl_FragColor = vec4(gradient, length(gradient));

