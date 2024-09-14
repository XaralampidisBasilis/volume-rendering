// gradient_tetrahedron4

/**
 * Calculates the gradient at a given position in 
 * a 3D texture using tetrachedron method and trilinear interpolation
 * https://iquilezles.org/articles/normalsSDF/
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */



// Define offsets for the 4 neighboring points
const vec2 k = vec2(-1.0, +1.0);
const vec3 sample_offset[4] = vec3[4]
(
    k.xxx,
    k.xyy,
    k.yxy,
    k.yyx
);

// Sample values at the neighboring points
float sample_value[4];
vec3 sample_texel;
vec3 sub_step = u_volume.inv_dimensions * 0.5;

#pragma unroll_loop_start
for (int i = 0; i < 4; i++)
{
    sample_texel = trace.texel + sub_step * sample_offset[i];
    sample_value[i] = texture(u_sampler.volume, sample_texel).r;
    sample_value[i] /= exp2(sum(outside(sub_step, 1.0 - sub_step, sample_texel))); // correct edge cases due to trillinear interpolation and clamp to edge wrapping   
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
trace.gradient.x = sample_value[2] + sample_value[3] - sample_value[0] - sample_value[1];
trace.gradient.y = sample_value[1] + sample_value[3] - sample_value[0] - sample_value[2];
trace.gradient.z = sample_value[1] + sample_value[2] - sample_value[0] - sample_value[3];
trace.gradient *= 0.5 * u_volume.inv_spacing; // // adjust gradient to physical space 
trace.gradient *= 8.0; // get integer kernel values from trilinear sampling
trace.gradient /= 10.0; // normalize the kernel values

trace.gradient_norm = length(trace.gradient);
trace.normal = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);


