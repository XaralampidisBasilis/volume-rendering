/**
 * Calculates the gradient at a given position in 
 * a 3D texture using tetrachedron method and trilinear interpolation
 * https://iquilezles.org/articles/normalsSDF/
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */


vec4 gradient_tetrahedron4
(
    in sampler3D volume_data, // assumes LinearFilter & ClampToEdgeWrapping
    in vec3 volume_spacing,
    in ivec3 volume_dimensions,
    in ivec3 voxel_coords
)
{
    // Define offsets for the 4 neighboring points
    const vec2 k = vec2(-1.0, +1.0);
    const vec3 samples_offset[4] = vec3[4]
    (
        k.xxx,
        k.xyy,
        k.yxy,
        k.yyx
    );
    
    // Calculate the position and step sizes within the 3D texture
    vec3 voxel_step = 1.0 / vec3(volume_dimensions);
    vec3 voxel_pos = (vec3(voxel_coords) + 0.5) * voxel_step;
    vec3 sub_step = voxel_step * 0.5;
   
    // Sample values at the neighboring points
    float samples[4];
    for (int i = 0; i < 4; i++)
    {
        vec3 sample_pos = voxel_pos + sub_step * samples_offset[i];
        samples[i] = texture(volume_data, sample_pos).r;

        // handle edge case problems due to trillinear interpolation and clamp to edge wrapping
        vec3 is_outside = outside(sub_step, 1.0 - sub_step, sample_pos);
        samples[i] /= exp2(sum(is_outside));  
    }

    // Calculate the gradient based on the sampled values using the Sobel operator
    vec3 gradient = vec3
    (
        samples[2] + samples[3] - samples[0] - samples[1],
        samples[1] + samples[3] - samples[0] - samples[2],
        samples[1] + samples[2] - samples[0] - samples[3]
    );

    // Get integer kernel values from trilinear sampling
    gradient *= 8.0;

    // Normalize the kernel values
    gradient /= 10.0;
  
    // Adjust gradient to physical space 
    gradient /= 2.0 * volume_spacing;

    // Combine results
    return vec4(normalize(gradient), length(gradient));
}
