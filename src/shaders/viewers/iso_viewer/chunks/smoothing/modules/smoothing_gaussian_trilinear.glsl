// https://homepages.inf.ed.ac.uk/rbf/HIPR2/gsmooth.htm
// https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel

vec3 sample_offset, sample_texel;
float sample_value, sample_kernel;

// Precompute values
vec3 texel_step = volume.inv_dimensions;
float sigma = float(SMOOTHING_RADIUS) / 3.0; 
float coeff = 1.0 / sqrt(TWO_PI * pow2(sigma));  
float kernel_sum = 0.0;          

// Precompute kernel
float kernel[SMOOTHING_RADIUS];

for (int i = 0; i < SMOOTHING_RADIUS; i++) 
    kernel[i] = coeff * gaussian(float(i) + 0.5, sigma);

// Initialize loop
trace.sample_value = 0.0;       

for (int x = -SMOOTHING_RADIUS; x < SMOOTHING_RADIUS; x++)  {
    float kernel_x = kernel[abs(x) - int(x < 0)];

    for (int y = -SMOOTHING_RADIUS; y < SMOOTHING_RADIUS; y++)  {
        float kernel_y = kernel[abs(y) - int(y < 0)];

        for (int z = -SMOOTHING_RADIUS; z < SMOOTHING_RADIUS; z++) {
            float kernel_z = kernel[abs(z) - int(z < 0)];

            // Compute sample texel position
            sample_offset = vec3(x, y, z) + 0.5;
            sample_texel = trace.voxel_texture_coords + texel_step * sample_offset;
            
            // Compute the gaussian kernel value
            // Apply the boundary check to the kernel value
            sample_kernel = kernel_x * kernel_y * kernel_z;
            
            // Sample value from the texture
            sample_value = textureLod(textures.volume, sample_texel, 0.0).r;

            // Accumulate the weighted sample and kernel sum
            trace.sample_value += sample_kernel * sample_value;
            kernel_sum += sample_kernel;
        }
    }
}

// Normalize the final trace value
trace.sample_value /= kernel_sum;

// Compute trace error relative to threshold
trace.sample_error = trace.sample_value - raymarch.sample_threshold;
