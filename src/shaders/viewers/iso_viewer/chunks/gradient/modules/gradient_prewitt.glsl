// gradient_prewitt27

// compute prewitt 27 kernels 
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

// define offsets for 26 neighboring samples
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

// sample values at neighboring points
vec3 texel_step = u_volume.inv_dimensions;
float sample_value[27];
vec3 sample_texel;

vec3 box_min = 0.0 - texel_step + EPSILON6;
vec3 box_max = 1.0 - box_min;

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    sample_texel = trace.texel + texel_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;
    sample_value[i] *= inside_box(box_min, box_max, sample_texel);
}
#pragma unroll_loop_end

// calculate the gradient based on sampled values
trace.gradient = vec3(0.0);

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    trace.gradient.x += kernel_x[i] * sample_value[i];
    trace.gradient.y += kernel_y[i] * sample_value[i];
    trace.gradient.z += kernel_z[i] * sample_value[i];
}
#pragma unroll_loop_end

trace.gradient /= 9.0; // normalize the kernel values
trace.gradient *= u_volume.inv_spacing * 0.5; // // adjust gradient to physical space 
trace.gradient_norm = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);
