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

vec3 sample_offset, sample_texel;
float sample_value;

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel center

// Precompute values
float size = float(2 * SMOOTHING_RADIUS);   // Size of the grid in each dimension
float sample_kernel = 1.0 / pow3(size);   
float smooth_value = 0.0;        

for (int x = -SMOOTHING_RADIUS; x < SMOOTHING_RADIUS; x++)  {

    for (int y = -SMOOTHING_RADIUS; y < SMOOTHING_RADIUS; y++)  {
        
        for (int z = -SMOOTHING_RADIUS; z < SMOOTHING_RADIUS; z++) {

            // Compute sample texel position
            sample_offset = vec3(x, y, z) + 0.5;
            sample_texel = voxel_texel + texel_step * sample_offset;
            
            // Sample value from the texture
            sample_value = textureLod(volume_data, sample_texel, 0.0).r;

            // Accumulate the weighted sample and kernel sum
            smooth_value += sample_kernel * sample_value;
        }
    }
}

gl_FragColor = vec4(vec3(smooth_value), 1.0);