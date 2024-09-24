// https://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm

// Define texel step and box boundaries
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;

// Main loop through kernel offsets
float min_value = 1.0;
float max_value = 0.0;

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {   
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Calculate the sample offset and texel position
            ivec3 sample_offset = ivec3(x, y, z);
            vec3 sample_texel = trace.texel + texel_step * vec3(sample_offset);

            // Check if the sample is within the bounding box
            float is_inside = inside_box(box_min, box_max, sample_texel);
            float is_offset = float(any(notEqual(sample_offset, ivec3(0))));

            // Sample the value from the texture
            float sample_value = texture(u_sampler.volume, sample_texel).r;
            
            min_value = min(min_value, mix(1.0, sample_value, is_inside * is_offset));
            max_value = max(max_value, mix(0.0, sample_value, is_inside * is_offset));
        }
    }
}

// Normalize the final trace value
trace.value = clamp(trace.value, min_value, max_value);

// Compute trace error relative to the raycast threshold
trace.error = trace.value - u_raycast.threshold;
