// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm

// compute mean smoothing kernel
float kernel_sum = 0.0;
const float[27] kernel = float[27]
(
    1.0,   1.0,  1.0,
    1.0,   1.0,  1.0,
    1.0,   1.0,  1.0,
    1.0,  1.0, 1.0,
    1.0,  1.0, 1.0,
    1.0,  1.0, 1.0,
    1.0,  1.0, 1.0,
    1.0,  1.0, 1.0,
    1.0,  1.0, 1.0
);


// Define offsets for the 27 neighboring samples
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

// Sample values at sample offsets
vec3 texel_step = u_volume.inv_dimensions;
float sample_value[27];
vec3 sample_texel;

vec3 box_min = 0.0 - texel_step + EPSILON6;
vec3 box_max = 1.0 - box_min;
float is_inside = 0.0;

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    sample_texel = trace.texel + texel_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;

    is_inside = inside_box(box_min, box_max, sample_texel);
    sample_value[i] *= is_inside;
    kernel_sum += kernel * is_inside;
}
#pragma unroll_loop_end

// Calculate the smoothed value based of mean smoothing kernel
trace.value = 0.0;

#pragma unroll_loop_start
for (int i = 0; i < 27; i++)
{
    trace.value += kernel[i] * sample_value[i];
}
#pragma unroll_loop_end

trace.value /= kernel_sum;
trace.error = trace.value - u_raycast.threshold;
