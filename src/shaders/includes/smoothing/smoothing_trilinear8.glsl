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

 // Define offsets for the 8 neighboring points using swizzling
const vec2 k = vec2(1.0, -1.0);
const vec3 k_offset[8] = vec3[8]
(
    k.xxx, k.xxy, 
    k.xyx, k.xyy, 
    k.yxx, k.yxy,
    k.yyx, k.yyy 
);

float smoothing_trilinear8
(
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    in float smoothing_factor
)
{
    // Define the smoothing step based on trilinear interpolation
    vec3 voxel_step = 1.0 / u_volume.dimensions;
    vec3 smoothing_step = smoothing_factor * voxel_step * 0.666666666667;
   
    // Sample values at the neighboring points
    float samples[8];

    for (int i = 0; i < 8; i++)
    {
        vec3 position = ray_position + smoothing_step * k_offset[i];
        samples[i] = sample_intensity_3d(u_sampler.volume, position);
    }

    // Combine the trilinear samples
    vec3 smooth_sample = 

        samples[4] + samples[5] + samples[6] + samples[7] +
        samples[0] + samples[1] + samples[2] + samples[3];

    // Normalize the result
    smooth_sample *= 0.125;

    return smooth_sample;
}
