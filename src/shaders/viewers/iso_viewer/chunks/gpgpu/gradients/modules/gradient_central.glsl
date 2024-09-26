
// Assumes volume texture with LinearFilter & ClampToEdgeWrapping

// Define offsets for the 8 neighboring points
const vec3 k = vec3(-1.0, 0.0, +1.0);
const vec3 sample_offset[6] = vec3[6]
(
    k.xyy, k.zyy, 
    k.yxy, k.yzy, 
    k.yyx, k.yyz
);

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel centers

// Sample values at the neighboring points
float sample_value[6];
vec3 sample_texel;

#pragma unroll_loop_start
for (int i = 0; i < 6; i++)
{
    sample_texel = voxel_texel + texel_step * sample_offset[i];
    sample_value[i] = textureLod(volume_data, sample_texel, 0.0).r;
    sample_value[i] *= inside_box(0.0, 1.0, sample_texel);
}
#pragma unroll_loop_end

// Calculate the gradient based on the sampled values using the Sobel operator
vec3 gradient = vec3
(
    sample_value[1] - sample_value[0],
    sample_value[3] - sample_value[2],
    sample_value[5] - sample_value[4]
);

// Adjust gradient to physical space 
gradient *= 0.5 * volume_inv_spacing;

// Combine results
gl_FragColor = vec4(gradient, length(gradient));

