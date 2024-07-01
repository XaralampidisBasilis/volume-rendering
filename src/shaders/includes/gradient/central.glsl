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
vec3 central(in sampler3D sampler_volume, in vec3 grad_step, in vec3 hit_position, inout float hit_intensity)
{
    vec3 k = vec3(1.0, -1.0, 0.0);

    // Define offsets for the 6 neighboring points using swizzling
    vec3 delta[6] = vec3[6](
        grad_step * k.xzz,  // Right
        grad_step * k.yzz,  // Left
        grad_step * k.zxz,  // Top
        grad_step * k.zyz,  // Bottom
        grad_step * k.zzx,  // Near
        grad_step * k.zzy   // Far
    );

    float samples[6];
    for (int i = 0; i < 6; i++)
    {
        samples[i] = texture(sampler_volume, hit_position + delta[i]).r;
    }

    vec3 normal = vec3(
        samples[1] - samples[0],
        samples[3] - samples[2],
        samples[5] - samples[4]
    );
    normal = normalize(normal);

    // Find the maximum value among the sampled points
    for (int i = 0; i < 6; i++) 
    {
        hit_intensity = max(hit_intensity, samples[i]);
    }

    
    return normal;
}

/* SOURCE
    Based on interpolated Sobel operator, offset needs to be off-grid to work properly
    typical value offset = 0.7 / volume_dimensions, for texel coordinates
    https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
*/
