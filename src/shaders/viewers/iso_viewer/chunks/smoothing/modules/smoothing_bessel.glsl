// https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel


// Define the texel step and bounding box
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;

// Main loop through kernel offsets
vec3 sample_offset, sample_texel;
float sample_value, kernel_value, is_inside;

float sigma = float(SMOOTHING_RADIUS) / 2.0; // Sigma derived from radius
float coeff = exp(-3.0 * sigma);  // Pre-compute constant coefficient
float kernel_sum = 0.0;            // To normalize the kernel values

trace.value = 0.0;              

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++)  {
    float bessix = besseli(abs(x), sigma);

    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++)  {
        float bessiy = besseli(abs(y), sigma);

        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {
            float bessiz = besseli(abs(z), sigma);

            // Compute sample texel position
            sample_texel = trace.texel + texel_step * vec3(x, y, z);
            
            // Check if sample is inside the bounding box
            is_inside = inside_box(box_min, box_max, sample_texel);

            // Sample value from the texture
            sample_value = texture(u_sampler.volume, sample_texel).r;

            // Compute the modified bessel of the first kind In kernel value
            kernel_value = coeff * bessix * bessiy * bessiz;

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

// Compute trace error relative to threshold
trace.error = trace.value - u_raycast.threshold;
