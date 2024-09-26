// https://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm

ivec3 sample_offset;
vec3 sample_texel;
float sample_value, is_zero;

// Calculate the position and step sizes within the 3D texture
vec3 texel_step = volume_inv_dimensions;
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel centers

// Main loop through kernel offsets
float smooth_value = 0.0;        
float min_value = 1.0;
float max_value = 0.0;

// Smoothing loop
for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {   
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            // Calculate the sample offset and texel position
            sample_offset = ivec3(x, y, z);
            sample_texel = voxel_texel + texel_step * vec3(sample_offset);

            // Check if the sample is zero offset
            is_zero = float(all(equal(sample_offset, ivec3(0))));

            // Sample the value from the texture
            sample_value = textureLod(volume_data, sample_texel, 0.0).r;
            
            min_value = min(min_value, mix(sample_value, 1.0, is_zero));
            max_value = max(max_value, mix(sample_value, 0.0, is_zero));
        }
    }
}

// Normalize the final trace value
smooth_value = textureLod(volume_data, voxel_texel, 0.0).r;
smooth_value = clamp(smooth_value, min_value, max_value);

// Compute trace error relative to the raycast threshold
gl_FragColor = vec4(vec3(smooth_value), 1.0);