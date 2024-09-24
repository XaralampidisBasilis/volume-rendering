// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm

// Define texel step and box boundaries
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;

// Main loop through kernel offsets
vec3 sample_offset, sample_texel;
float sample_value, kernel_value, is_inside;

float sigma = float(SMOOTHING_RADIUS) / 2.0; // Sigma derived from radius
float coeff = 1.0 / pow(TWO_PI * sigma, 3.0 / 2.0); 
float kernel_sum = 0.0; // Initialize kernel sum for normalization

trace.value = 0.0;                // Initialize trace value to zero

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {

    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {

        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Calculate the sample offset and texel position
            sample_offset = vec3(x, y, z);
            sample_texel = trace.texel + texel_step * sample_offset;

            // Check if the sample is within the bounding box
            is_inside = inside_box(box_min, box_max, sample_texel);

            // Sample the value from the texture
            sample_value = texture(u_sampler.volume, sample_texel).r * is_inside;

            // Compute the Gaussian kernel value
            kernel_value = coeff * gaussian(sample_offset, sigma);

            // Apply the boundary check to the kernel value
            kernel_value *= is_inside;

            // Accumulate the weighted sample and kernel sum
            trace.value += kernel_value * sample_value;
            kernel_sum += kernel_value;
        }
        #pragma unroll_loop_end
    }
    #pragma unroll_loop_end
}
#pragma unroll_loop_end

// Normalize the final trace value
trace.value /= kernel_sum;

// Compute trace error relative to the raycast threshold
trace.error = trace.value - u_raycast.threshold;
