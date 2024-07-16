/**
 * Calculates the gradient and maximum intensity at a given position in a 3D texture using the central differences approximation.
 *
 * @param sampler_volume: 3D texture sampler containing intensity data
 * @param grad_step: Step vector for sampling the 3D texture
 * @param volume_uvw: Position in the 3D texture to calculate the gradient
 * @param intensity_max: Output float where the maximum intensity of the sampled points will be stored
 *
 * @return vec3: Gradient vector at the given position
 */
vec3 gradient_central(in sampler3D sampler_volume, in vec3 gradient_step, in vec3 ray_position, inout float max_sample, out float gradient_magnitude)
{
    vec3 k = vec3(1.0, -1.0, 0.0);

    // Define offsets for the 6 neighboring points using swizzling
    vec3 delta[6] = vec3[6](
        gradient_step * k.xzz,  // Right
        gradient_step * k.yzz,  // Left
        gradient_step * k.zxz,  // Top
        gradient_step * k.zyz,  // Bottom
        gradient_step * k.zzx,  // Near
        gradient_step * k.zzy   // Far
    );

    float samples[6];
    for (int i = 0; i < 6; i++)
    {
        samples[i] = texture(sampler_volume, ray_position + delta[i]).r;
        max_sample = max(max_sample, samples[i]);
    }

    // compute gradient vector
    vec3 gradient_vector = vec3(
        samples[1] - samples[0],
        samples[3] - samples[2],
        samples[5] - samples[4]
    );
    
    gradient_magnitude = length(gradient_vector);
    gradient_vector = normalize(gradient_vector);

   
    
    return gradient_vector;
}

/* SOURCE
    Based on interpolated Sobel operator, offset needs to be off-grid to work properly
    typical value offset = 0.7 / volume_dimensions, for texel coordinates
    https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
*/