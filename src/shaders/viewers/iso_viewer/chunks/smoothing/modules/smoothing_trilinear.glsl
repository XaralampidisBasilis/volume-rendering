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

int size = 2 * SMOOTHING_RADIUS + 1;   // Size of the grid in each dimension

// Define texel step and box boundaries
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;

float coeff = 1.0 / pow3(size); 
float kernel_sum = 0.0; // Initialize kernel sum for normalization

// Main loop through kernel offsets
trace.value = 0.0;  // Initialize trace value to zero

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Calculate the sample offset and texel position
            vec3 sample_offset = vec3(x, y, z);
            vec3 sample_texel = trace.texel + texel_step * sample_offset;

            // Check if the sample is within the bounding box
            float is_inside = inside_box(box_min, box_max, sample_texel);

            // Sample the value from the texture
            float sample_value = texture(u_sampler.volume, sample_texel).r * is_inside;

            // Compute the mean smoothing kernel value
            float kernel_value = coeff;

            // Apply the boundary check to the kernel value
            kernel_value *= is_inside;

            // Accumulate the weighted sample and kernel sum
            trace.value += kernel_value * sample_value;
            kernel_sum += kernel_value;
        }
    }
}

// Normalize the final trace value
trace.value /= kernel_sum;

// Normalize the result
smooth_sample /= 8.0;

// Compute trace error relative to the raycast threshold
trace.error = trace.value - u_raycast.threshold;
