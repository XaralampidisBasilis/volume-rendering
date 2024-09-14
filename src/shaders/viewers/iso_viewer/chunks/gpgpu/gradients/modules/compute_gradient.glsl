#include "./gradient_sobel8"
#include "./gradient_sobel27"
#include "./gradient_scharr27"
#include "./gradient_prewitt27"
#include "./gradient_central6"
#include "./gradient_tetrahedron4"
#include "./gradient_tetrahedron27"

/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using either the 3 following methods.
 *  1. sobel, 2. central differences approximation, 3. tetrachedron method
 *
 * @param data: 3D texture sampler containing intensity data
 * @param pos: Position in the 3D texture to calculate the gradient
 * @param step: Step vector for sampling the 3D texture
 *
 * @param normal: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec4 compute_gradient
(
    in sampler3D volume_data, 
    in vec3 volume_spacing, 
    in ivec3 volume_dimensions, 
    in ivec3 voxel_coords,
    in int gradient_method
)
{    
    switch (gradient_method)
    {
        case 1: 
            return gradient_sobel8(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 2: 
            return gradient_sobel27(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 3: 
            return gradient_scharr27(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 4: 
            return gradient_prewitt27(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 5: 
            return gradient_central6(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 6: 
            return gradient_tetrahedron4(volume_data, volume_spacing, volume_dimensions, voxel_coords);
        case 7: 
            return gradient_tetrahedron27(volume_data, volume_spacing, volume_dimensions, voxel_coords);
    }
}
