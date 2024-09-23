// https://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm

// Define offsets for the 26 neighboring samples, except center
const vec3 k = vec3(-1.0, 0.0, +1.0);
const vec3[26] sample_offset = vec3[26]
(
     k.xxx,   k.xxy,   k.xxz,  
     k.xyx,   k.xyy,   k.xyz,  
     k.xzx,   k.xzy,   k.xzz,
     k.yxx,  k.yxy,  k.yxz, 
    k.yyx,               k.yyz,
    k.yzx,  k.yzy,  k.yzz,
    k.zxx,  k.zxy,  k.zxz, 
    k.zyx,  k.zyy,  k.zyz, 
    k.zzx,  k.zzy,  k.zzz
);

// Sample values at sample offsets
vec3 texel_step = u_volume.inv_dimensions;
vec3 sample_texel;
float sample_value;
float min_value = 1;
float max_value = 0;

vec3 box_min = 0.0 - texel_step + EPSILON6;
vec3 box_max = 1.0 - box_min;
float is_inside = 0.0;

#pragma unroll_loop_start
for (int i = 0; i < 26; i++)
{
    sample_texel = trace.texel + texel_step * sample_offset[i];
    sample_value = texture(u_sampler.volume, sample_texel).r;

    is_inside = inside_box(box_min, box_max, sample_texel);
    min_value = min(min_value, mix(1.0, sample_value, is_inside));
    max_value = max(max_value, max(0.0, sample_value, is_inside));
}
#pragma unroll_loop_end

trace.value = clamp(trace.value, min_value, max_value);
trace.error = trace.value - u_raycast.threshold;
