// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm

vec3 sample_offset, sample_texel;
float sample_value;

// Define the texel step and bounding box
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;

// Precompute values
float size = float(2 * SMOOTHING_RADIUS + 1);   // Size of the grid in each dimension
float sample_kernel = 1.0 / pow3(size);  
float kernel_sum = 0.0;            

trace.value = 0.0;       

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++)  {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++)  {
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Compute sample texel position
            sample_offset = vec3(x, y, z);
            sample_texel = trace.texel + texel_step * sample_offset;
            
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
