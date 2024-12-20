// https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel

vec3 sample_offset, sample_texel;
float sample_value, sample_kernel;

// Precompute values
vec3 texel_step = u_volume.inv_dimensions;
float sigma2 = pow2(float(SMOOTHING_RADIUS) / 3.0); 
float coeff = exp(-sigma2);  
float kernel_sum = 0.0;   

// Precompute kernel
float kernel[SMOOTHING_RADIUS + 1];

for (int i = 0; i <= SMOOTHING_RADIUS; i++) 
    kernel[i] = coeff * besseli(i, sigma2);

// Initialize loop
trace.value = 0.0;        

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++)  {
    float kernel_x = kernel[abs(x)];

    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++)  {
        float kernel_y = kernel[abs(y)];

        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {
            float kernel_z = kernel[abs(z)];

            // Compute sample texel position
            sample_offset = vec3(x, y, z);
            sample_texel = trace.texel + texel_step * sample_offset;
            
            // Compute the modified bessel of the first kind kernel value
            // Apply the boundary check to the kernel value
            sample_kernel = kernel_x * kernel_y * kernel_z;
            
            // Sample value from the texture
            sample_value = textureLod(u_sampler.volume, sample_texel, 0.0).r;

            // Accumulate the weighted sample and kernel sum
            trace.value += sample_kernel * sample_value;
            kernel_sum += sample_kernel;
        }
    }
}

// Normalize the final trace value
trace.value /= kernel_sum;

// Compute trace error relative to threshold
trace.error = trace.value - u_raycast.threshold;
