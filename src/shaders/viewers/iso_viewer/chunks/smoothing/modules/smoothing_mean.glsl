// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm

vec3 sample_offset, sample_texel;
float sample_value;

// Precompute values
vec3 texel_step = u_volume.inv_dimensions;
float size = float(2 * SMOOTHING_RADIUS + 1);   // Size of the grid in each dimension
float sample_kernel = 1.0 / pow3(size);  

trace.sample = 0.0;       

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++)  {

    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++)  {
        
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Compute sample texel position
            sample_offset = vec3(x, y, z);
            sample_texel = trace.voxel_texture_coords + texel_step * sample_offset;
            
            // Sample value from the texture
            sample_value = textureLod(u_sampler.volume, sample_texel, 0.0).r;

            // Accumulate the weighted sample and kernel sum
            trace.sample += sample_kernel * sample_value;
        }
    }
}

// Compute trace error relative to threshold
trace.sample_error = trace.sample - raymarch.sample_threshold;
