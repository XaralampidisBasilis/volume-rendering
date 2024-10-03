// https://homepages.inf.ed.ac.uk/rbf/HIPR2/gsmooth.htm
// https://www.wikiwand.com/en/articles/Sampled_Gaussian_kernel

vec3 sample_offset, sample_texel;
float sample_value, sample_kernel;

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel center

// Precompute values
float sigma = float(SMOOTHING_RADIUS) / 3.0; 
float coeff = 1.0 / sqrt(TWO_PI * pow2(sigma));  
float kernel_sum = 0.0;          
float smooth_value = 0.0;        

// Precompute kernel
float kernel[SMOOTHING_RADIUS];

for (int i = 0; i < SMOOTHING_RADIUS; i++) 
    kernel[i] = coeff * gaussian(float(i) + 0.5, sigma);

// Smoothing loop
for (int x = -SMOOTHING_RADIUS; x < SMOOTHING_RADIUS; x++)  {
    float kernel_x = kernel[abs(x) - int(x < 0)];

    for (int y = -SMOOTHING_RADIUS; y < SMOOTHING_RADIUS; y++)  {
    float kernel_y = kernel[abs(y) - int(y < 0)];

        for (int z = -SMOOTHING_RADIUS; z < SMOOTHING_RADIUS; z++) {
    float kernel_z = kernel[abs(z) - int(z < 0)];

            // Compute sample texel position
            sample_offset = vec3(x, y, z) + 0.5;
            sample_texel = voxel_texel + texel_step * sample_offset;
            
            // Compute the gaussian kernel value
            // Apply the boundary check to the kernel value
            sample_kernel = kernel_x * kernel_y * kernel_z;
            
            // Sample value from the texture
            sample_value = textureLod(volume_data, sample_texel, 0.0).r;

            // Accumulate the weighted sample and kernel sum
            smooth_value += sample_kernel * sample_value;
            kernel_sum += sample_kernel;
        }
    }
}

// Normalize the final trace value
smooth_value /= kernel_sum;

gl_FragColor = vec4(vec3(smooth_value), 1.0);