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

 #include "../../libraries/lygia/math/gaussian"

float smooth_gaussian
(
    in sampler3D volume_data,
    in vec3 volume_size,
    in vec3 volume_spacing,
    in vec3 volume_dimensions,
    in vec3 voxel_coords
)
{
    float voxel_spacing = min(volume_spacing.x, min(volume_spacing.y, volume_spacing.z));
    vec3 voxel_position = voxel_coords / volume_dimensions;
    vec3 voxel_step = voxel_spacing / volume_size;

    // Define offsets for the 24 neighboring points using k vector with swizzling
    vec3 k = vec3(1.0, 0.0, -1.0);

    vec3 voxel_offset[27] = vec3[27]
    (
        // Face 1 (x = 1)
        voxel_step * k.xxx,  // ( 1,  1,  1) // 3 //
        voxel_step * k.xxy,  // ( 1,  1,  0) // 2 //
        voxel_step * k.xxz,  // ( 1,  1, -1) // 3 //
        voxel_step * k.xyx,  // ( 1,  0,  1) // 2 //
        voxel_step * k.xyy,  // ( 1,  0,  0) // 1 //
        voxel_step * k.xyz,  // ( 1,  0, -1) // 2 //
        voxel_step * k.xzx,  // ( 1, -1,  1) // 3 //
        voxel_step * k.xzy,  // ( 1, -1,  0) // 2 //
        voxel_step * k.xzz,  // ( 1, -1, -1) // 3 //

        // Face 2 (x = 0)
         voxel_step * k.yxx, // ( 0,  1,  1) // 2 // 
        voxel_step * k.yxy, // ( 0,  1,  0) // 1 //
        voxel_step * k.yxz, // ( 0,  1, -1) // 2 // 
        voxel_step * k.yyx, // ( 0,  0,  1) // 1 //
        voxel_step * k.yyy, // ( 0,  0,  0) // 0 //
        voxel_step * k.yyz, // ( 0,  0, -1) // 1 //
        voxel_step * k.yzx, // ( 0, -1,  1) // 2 //
        voxel_step * k.yzy, // ( 0, -1,  0) // 1 //
        voxel_step * k.yzz, // ( 0, -1, -1) // 2 //

        // Face 2 (x = -1)
        voxel_step * k.zxx, // (-1,  1,  1) // 3 //
        voxel_step * k.zxy, // (-1,  1,  0) // 2 //
        voxel_step * k.zxz, // (-1,  1, -1) // 3 //
        voxel_step * k.zyx, // (-1,  0,  1) // 2 //
        voxel_step * k.zyy, // (-1,  0,  0) // 1 //
        voxel_step * k.zyz, // (-1,  0, -1) // 2 //
        voxel_step * k.zzx, // (-1, -1,  1) // 3 //
        voxel_step * k.zzy, // (-1, -1,  0) // 2 //
        voxel_step * k.zzz, // (-1, -1, -1) // 3 //
    );

    // Sample values at the neighboring points    
    float samples[27];
    float gaussian_kernel[27];
    const float sigma = 0.5;

    for (int i = 0; i < 27; i++)
    {
        vec3 position = voxel_position + voxel_offset[i];

        samples[i] = sample_intensity_3d(volume_data, position);
        gaussian_kernel[i] = gaussian(position * volume_size, sigma);
    }

    // Normalize the kernel
    float sum = 0.0;
    for (int i = 0; i < 27; i++) 
        sum += gaussian_kernel[i];
    
    for (int i = 0; i < 27; i++) 
        gaussian_kernel[i] /= sum;
    
    // Calculate the gradient using the Sobel operator
    float smooth_sample = 0.0;
    
    for (int i = 0; i < 27; i++)
        smooth_sample += gaussian_kernel[i] * samples[i];
    
   
    return smooth_sample; 
}
