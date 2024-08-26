/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using the Sobel operator.
 *
 * @param sampler_volume: 3D texture sampler containing intensity data
 * @param grad_step: Step vector for sampling the 3D texture
 * @param hit_position: Position in the 3D texture to calculate the gradient
 * @param intensity_max: Output float where the maximum value of the sampled points will be stored
 *
 * @return vec3: Gradient vector at the given position
 */

#include "./sobel26_kernels"

vec3 gradient_sobel26
(
    in sampler3D volume_data,
    in vec3 volume_size,
    in vec3 volume_spacing,
    in vec3 volume_dimensions,
    in vec3 voxel_coords,
    out float voxel_sample
)
{
    float voxel_spacing = min(volume_spacing.x, min(volume_spacing.y, volume_spacing.z));
    vec3 voxel_position = voxel_coords / volume_dimensions;
    vec3 voxel_step = voxel_spacing / volume_size;

    // Sample values at the neighboring points    
    float samples[27];

    for (int i = 0; i < 27; i++)
    {
        vec3 position = voxel_position + voxel_step * sobel_k_offset[i];

        samples[i] = texture(volume_data, position).r;
        samples[i] *= inside_texture(position);
    }

    // retrive the voxel sample
    voxel_sample = samples[13];

    // Calculate the gradient using the Sobel operator
    vec3 gradient_vector = vec3(0.0);
    
    for (int i = 0; i < 27; i++)
    {
        gradient_vector.x += sobel_kernel_x[i] * samples[i];
        gradient_vector.y += sobel_kernel_y[i] * samples[i];
        gradient_vector.z += sobel_kernel_z[i] * samples[i];
    }
    
    return gradient_vector / sobel_max_length;
}
