/**
 * Smooths the intensity at a given position in a 3D texture using trilinear interpolation.
 *
 * @param volume_data: 3D texture sampler containing intensity data
 * @param volume_dimensions: Dimensions of the 3D texture
 * @param voxel_coords: Coordinates of the voxel in the 3D texture
 * @param smoothing_factor: Factor to adjust the smoothing step size in range [0, 1], 
 * zero meaning no smoothing, and 1 meaning full smothing with neighboors
 *
 * @return float: Smoothed intensity value at the given position
 */

// Calculate the position and step sizes within the 3D texture
vec3 voxel_step = 1.0 / vec3(volume_dimensions);
vec3 voxel_pos = voxel_step * (vec3(voxel_coords) + 0.5);
vec3 substep = voxel_step * smoothing_factor * 2.0 / 3.0;

// Define offsets for the 8 neighboring points
const vec2 k = vec2(1.0, -1.0);

const vec3 samples_offset[8] = vec3[8]
(
    k.xxx, k.xxy, 
    k.xyx, k.xyy, 
    k.yxx, k.yxy,
    k.yyx, k.yyy 
);

// Sample values at the neighboring points
float samples[8];
for (int i = 0; i < 8; i++)
{
    vec3 sample_pos = voxel_pos + substep * samples_offset[i];;
    samples[i] = texture(volume_data, sample_pos).r;
}

// Combine the trilinear samples
float smooth_sample = 0.0;
for (int i = 0; i < 8; i++)
{
    smooth_sample += samples[i];
}

// Normalize the result
smooth_sample /= 8.0;

return smooth_sample;

