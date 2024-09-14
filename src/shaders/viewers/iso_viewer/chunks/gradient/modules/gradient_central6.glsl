// gradient_central6

// define offsets for 8 neighboring points
const vec3 k = vec3(-1.0, 0.0, +1.0);
const vec3 sample_offset[6] = vec3[6]
(
    k.xyy, k.zyy, 
    k.yxy, k.yzy, 
    k.yyx, k.yyz
);

// sample values at neighboring points
float sample_value[6];
vec3 sample_texel;
vec3 voxel_step = u_volume.inv_dimensions;

#pragma unroll_loop_start
for (int i = 0; i < 6; i++)
{
    sample_texel = trace.texel + voxel_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;
    sample_value[i] *= inside_box(0.0, 1.0, sample_texel);
}
#pragma unroll_loop_end

// calculate the gradient based on sampled values
trace.gradient.x = sample_value[1] - sample_value[0];
trace.gradient.y = sample_value[3] - sample_value[2];
trace.gradient.z = sample_value[5] - sample_value[4];
trace.gradient *= 0.5 * u_volume.inv_spacing; // adjust gradient to physical space 

trace.gradient_norm = length(trace.gradient);
trace.normal = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);

