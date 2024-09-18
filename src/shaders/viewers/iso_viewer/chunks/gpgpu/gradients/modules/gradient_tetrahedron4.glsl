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

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions * 0.5;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel centers

// Sample values at the neighboring points
float sample_value[4];
vec3 sample_texel;
vec3 is_outside;

for (int i = 0; i < 4; i++)
{
    sample_texel = voxel_texel + texel_step * sample_offset[i];
    sample_value[i] = texture(volume_data, sample_texel).r;

    // handle edge cases, due to trillinear interpolation and clamp to edge wrapping   
    is_outside = outside(texel_step, 1.0 - texel_step, sample_texel);
    sample_value[i] /= exp2(sum(is_outside)); 
}

// Calculate the gradient based on the sampled values using the Sobel operator
vec3 gradient = vec3
(
    sample_value[2] + sample_value[3] - sample_value[0] - sample_value[1],
    sample_value[1] + sample_value[3] - sample_value[0] - sample_value[2],
    sample_value[1] + sample_value[2] - sample_value[0] - sample_value[3]
);

// Get integer kernel values from trilinear sampling
gradient *= 8.0;

// Normalize the kernel values
gradient /= 10.0;

// Adjust gradient to physical space 
gradient *= 0.5 * volume_inv_spacing;

// Combine results
gl_FragColor = vec4(gradient, length(gradient));

