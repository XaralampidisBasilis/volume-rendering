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

vec4 gradient_smoothing_sobel8
(
    in sampler3D volume_data, // assumes LinearFilter & ClampToEdgeWrapping
    in ivec3 volume_dimensions,
    in ivec3 voxel_coords
)
{
    // Calculate the position and step sizes within the 3D texture
    vec3 voxel_step = 1.0 / vec3(volume_dimensions);
    vec3 voxel_pos = voxel_step * (vec3(voxel_coords) + 0.5);
    vec3 gradient_step = voxel_step * 0.5;
   
    // Define offsets for the 8 neighboring points
    const vec2 k = vec2(-1.0, +1.0);
    const vec3 k_offset[8] = vec3[8]
    (
        k.xxx, k.xxy, 
        k.xyx, k.xyy, 
        k.yxx, k.yxy,
        k.yyx, k.yyy 
    );
    
    // Sample values at the neighboring points
    float samples[8];
    
    for (int i = 0; i < 8; i++)
    {
        vec3 neighbor_step = gradient_step * k_offset[i];
        vec3 sample_pos = voxel_pos + neighbor_step;

        samples[i] = texture(volume_data, sample_pos).r;
    }

    // Calculate the gradient based on the sampled values using the Sobel operator
    vec3 gradient = vec3
    (
        samples[4] + samples[5] + samples[6] + samples[7] - samples[0] - samples[1] - samples[2] - samples[3],
        samples[2] + samples[3] + samples[6] + samples[7] - samples[0] - samples[1] - samples[4] - samples[5],
        samples[1] + samples[3] + samples[5] + samples[7] - samples[0] - samples[2] - samples[4] - samples[6]
    );

    // adjust gradient scale due to trilinear sampling dividing with 8
    // this gives us the classical sobel operator [1 2 1; 2 4 2; 1 2 1]
    // gradient *= 8.0; // multiply with 8        

    // normalize the coefficients of the sobel operator [1 2 1; 2 4 2; 1 2 1] / 16 to sum to 1
    // gradient *= 0.0625; // divide with 16              

    // normalize with the maximum possible gradient vector length 4 when samples in range [0, 1]
    // adjust gradient vector in range [-1, 1] for correct encoding
    gradient *= 0.25; // divide with 4  

    // adjust gradient vector in range [0, 1] for correct encoding
    gradient = gradient * 0.5 + 0.5;  

    // Calculate smooth sample based on the sum of neighbor trilinear samples
    float smooth_sample = 
    (
        samples[0] + samples[1] + samples[2] + samples[3] + samples[4] + samples[5] + samples[6] + samples[7]
    );

    // Adjust smooth sample
    smooth_sample *= 0.125;     // adjust smooth sample scale due to trilinear sampling dividing with 8

    // Combine results
    return vec4(smooth_sample, gradient);
}
