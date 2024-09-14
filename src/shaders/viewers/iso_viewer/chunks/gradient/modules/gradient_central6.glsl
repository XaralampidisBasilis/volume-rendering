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


// Define offsets for the 8 neighboring points
const vec3 k = vec3(-1.0, 0.0, +1.0);
const vec3 samples_offset[6] = vec3[6]
(
    k.xyy, k.zyy, 
    k.yxy, k.yzy, 
    k.yyx, k.yyz
);

// Calculate the position and step sizes within the 3D texture
vec3 voxel_step = vec3(u_volume.inv_dimensions);
vec3 voxel_pos = (vec3(voxel_coords) + 0.5) * voxel_step; // we need 0.5 to go to voxel centers

// Sample values at the neighboring points
float samples[6];
for (int i = 0; i < 6; i++)
{
    vec3 sample_pos = voxel_pos + voxel_step * samples_offset[i];
    samples[i] = texture(volume_data, sample_pos).r;
    samples[i] *= inside_box(0.0, 1.0, sample_pos);
}

// Calculate the gradient based on the sampled values using the Sobel operator
vec3 gradient = vec3
(
    samples[1] - samples[0],
    samples[3] - samples[2],
    samples[5] - samples[4]
);

// Adjust gradient to physical space 
gradient /= 2.0 * volume_spacing;

// Combine results
return vec4(normalize(gradient), length(gradient));

