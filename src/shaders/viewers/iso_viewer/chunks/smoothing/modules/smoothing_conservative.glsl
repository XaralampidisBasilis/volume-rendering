// https://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm

ivec3 sample_offset;
vec3 sample_texel;
float sample_value, is_zero;

// Main loop through kernel offsets
vec3 texel_step = u_volume.inv_dimensions;
float min_value = 1.0;
float max_value = 0.0;

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {   
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Calculate the sample offset and texel position
            sample_offset = ivec3(x, y, z);
            sample_texel = trace.voxel_texture_coords + texel_step * vec3(sample_offset);

            // Check if the sample is zero offset
            is_zero = float(all(equal(sample_offset, ivec3(0))));

            // Sample the value from the texture
            sample_value = textureLod(u_sampler.volume, sample_texel, 0.0).r;
            
            min_value = min(min_value, mix(sample_value, 1.0, is_zero));
            max_value = max(max_value, mix(sample_value, 0.0, is_zero));
        }
    }
}

// Normalize the final trace value
trace.sample = clamp(trace.sample, min_value, max_value);

// Compute trace error relative to the raycast threshold
trace.sample_error = trace.sample - raymarch.sample_threshold;
