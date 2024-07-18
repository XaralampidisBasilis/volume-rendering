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
vec3 gradient_central
(
    in uniforms_gradient u_gradient, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    inout float ray_sample, 
    out float ray_gradient
)
{
    float voxel_spacing = min(u_volume.spacing.x, min(u_volume.spacing.y, u_volume.spacing.z));
    vec3 voxel_step = voxel_spacing / u_volume.size;

    vec3 k = vec3(1.0, 0.0, -1.0);
    vec3 gradient_step = voxel_step / u_gradient.resolution;

    // Define offsets for the 6 neighboring points using swizzling
    vec3 offset[6] = vec3[6](
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
        vec3 ray_offset = ray_position + offset[i];
        samples[i] = sample_intensity_3d(u_sampler.volume, ray_offset) * inside_texture(ray_offset);

        if (u_gradient.max_sampling) 
            ray_sample = max(ray_sample, samples[i]); 
    }

    // compute gradient vector
    vec3 gradient_vector = vec3(
        samples[1] - samples[0],
        samples[3] - samples[2],
        samples[5] - samples[4]
    );
    ray_gradient = length(gradient_vector);

    return normalize(gradient_vector);
}

/* SOURCE
    Based on interpolated Sobel operator, offset needs to be off-grid to work properly
    typical value offset = 0.7 / volume_dimensions, for texel coordinates
    https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
*/
