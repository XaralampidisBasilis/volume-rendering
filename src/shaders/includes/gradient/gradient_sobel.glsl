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
vec3 gradient_sobel
(
    in uniforms_gradient u_gradient, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    inout float ray_sample, 
    out float gradient_magnitude
)
{
    float voxel_spacing = min(u_volume.spacing.x, min(u_volume.spacing.y, u_volume.spacing.z));
    vec3 voxel_step = voxel_spacing / u_volume.size;

    vec2 k = vec2(1.0, -1.0);
    vec3 gradient_step = voxel_step / u_gradient.resolution;

    // Define offsets for the 8 neighboring points using swizzling
    vec3 offset[8] = vec3[8](
        gradient_step * k.xxx,  // Right Top Near
        gradient_step * k.xxy,  // Right Top Far
        gradient_step * k.xyx,  // Right Bottom Near
        gradient_step * k.xyy,  // Right Bottom Far
        gradient_step * k.yxx,  // Left Top Near
        gradient_step * k.yxy,  // Left Top Far
        gradient_step * k.yyx,  // Left Bottom Near
        gradient_step * k.yyy   // Left Bottom Far
    );

    // Sample values at the neighboring points
    float samples[8];
    for (int i = 0; i < 8; i++)
    {
        vec3 ray_offset = ray_position + offset[i];
        samples[i] = sample_intensity_3d(u_sampler.volume, ray_offset) * inside_texture(ray_offset);

        if (u_gradient.max_sampling) 
            ray_sample = max(ray_sample, samples[i]); 
    }

    // Calculate the gradient using the Sobel operator
    vec3 gradient_vector = vec3(
        samples[4] + samples[5] + samples[6] + samples[7] - samples[0] - samples[1] - samples[2] - samples[3],
        samples[2] + samples[3] + samples[6] + samples[7] - samples[0] - samples[1] - samples[4] - samples[5],
        samples[1] + samples[3] + samples[5] + samples[7] - samples[0] - samples[2] - samples[4] - samples[6]
    );

    gradient_magnitude = length(gradient_vector) * 0.25;
    gradient_vector = normalize(gradient_vector);

    return gradient_vector;
}
