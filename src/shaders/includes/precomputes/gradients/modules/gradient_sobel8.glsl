/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using trilinear interpolation sobel operator and smoothing
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */


vec4 gradient_sobel8
(
    in sampler3D volume_data, // assumes LinearFilter & ClampToEdgeWrapping
    in vec3 volume_spacing,
    in ivec3 volume_dimensions,
    in ivec3 voxel_coords
)
{

    // Define offsets for the 8 neighboring points
    const vec2 k = vec2(-1.0, +1.0);
    const vec3 samples_offset[8] = vec3[8]
    (
        k.xxx, k.xxy, 
        k.xyx, k.xyy, 
        k.yxx, k.yxy,
        k.yyx, k.yyy 
    );
    
    // Calculate the position and step sizes within the 3D texture
    vec3 voxel_step = 1.0 / vec3(volume_dimensions);
    vec3 voxel_pos = voxel_step * (vec3(voxel_coords) + 0.5); // we need 0.5 to go to voxel centers
    vec3 substep = voxel_step * 0.5;
   
    // Sample values at the neighboring points
    float samples[8];
    for (int i = 0; i < 8; i++)
    {
        vec3 sample_pos = voxel_pos + substep * samples_offset[i];
        samples[i] = texture(volume_data, sample_pos).r;
        samples[i] *= inside_box(substep, 1.0 - substep, sample_pos);

    }

    // Calculate the gradient based on the sampled values using the Sobel operator
    vec3 gradient = vec3
    (
        samples[4] + samples[5] + samples[6] + samples[7] - samples[0] - samples[1] - samples[2] - samples[3],
        samples[2] + samples[3] + samples[6] + samples[7] - samples[0] - samples[1] - samples[4] - samples[5],
        samples[1] + samples[3] + samples[5] + samples[7] - samples[0] - samples[2] - samples[4] - samples[6]
    );

    // Get sobel kernel values from trilinear sampling
    gradient *= 8.0;

    // Normalize the kernel values
    gradient /= 16.0;
  
    // Adjust gradient to physical space 
    gradient /= 2.0 * volume_spacing;

    // Combine results
    return vec4(normalize(gradient), length(gradient));
}
