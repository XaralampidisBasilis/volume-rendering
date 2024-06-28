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
vec3 sobel(in sampler3D sampler_volume, in vec3 grad_step, in vec3 hit_position, inout float hit_intensity)
{
    vec2 k = vec2(1.0, -1.0);

    // Define offsets for the 8 neighboring points using swizzling
    vec3 delta[8] = vec3[8](
        grad_step * k.xxx,  // Right Top Near
        grad_step * k.xxy,  // Right Top Far
        grad_step * k.xyx,  // Right Bottom Near
        grad_step * k.xyy,  // Right Bottom Far
        grad_step * k.yxx,  // Left Top Near
        grad_step * k.yxy,  // Left Top Far
        grad_step * k.yyx,  // Left Bottom Near
        grad_step * k.yyy   // Left Bottom Far
    );

    // Sample the values at the neighboring points
    float samples[8];
    for (int i = 0; i < 8; i++)
    {
        samples[i] = sample_intensity_3d(sampler_volume, hit_position + delta[i]);
    }

    // Calculate the gradient using the Sobel operator
    vec3 normal = vec3(
        samples[4] + samples[5] + samples[6] + samples[7] - samples[0] - samples[1] - samples[2] - samples[3],
        samples[2] + samples[3] + samples[6] + samples[7] - samples[0] - samples[1] - samples[4] - samples[5],
        samples[1] + samples[3] + samples[5] + samples[7] - samples[0] - samples[2] - samples[4] - samples[6]
    );
    normal = normalize(normal);

    // Find the maximum value among the sampled points
    for (int i = 0; i < 8; i++) 
    {
        hit_intensity = max(hit_intensity, samples[i]);
    }

    return normal;
}
