/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using the tetrahedron method.
 *
 * @param sampler_volume: 3D texture sampler containing intensity data
 * @param grad_step: Step vector for sampling the 3D texture
 * @param volume_uvw: Position in the 3D texture to calculate the gradient
 * @param intensity_max: Output float where the maximum value of the sampled points will be stored
 *
 * @return vec3: Gradient vector at the given position
 */
vec3 tetrahedron(in sampler3D sampler_volume, in vec3 grad_step, in vec3 hit_position, inout float hit_intensity)
{
    vec2 k = vec2(1.0, -1.0);

    // Define offsets for the 4 neighboring points using swizzling
    vec3 delta[4] = vec3[4](
        grad_step * k.xxx,  // Right Top Near
        grad_step * k.xyy,  // Right Bottom Far
        grad_step * k.yxy,  // Left Top Far
        grad_step * k.yyx   // Left Bottom Near
    );

    float samples[4];
    for (int i = 0; i < 4; i++)
    {
        samples[i] = texture(sampler_volume, hit_position + delta[i]).r;
    }

    vec3 normal = vec3(
        samples[2] + samples[3] - samples[0] - samples[1],
        samples[1] + samples[3] - samples[0] - samples[2],
        samples[1] + samples[2] - samples[0] - samples[3]
    );
    normal = normalize(normal);

    // Find the maximum value among the sampled points
    for (int i = 0; i < 4; i++) 
    {
        hit_intensity = max(hit_intensity, samples[i]);
    }

    return normal;
    
    // For visual debug
    // gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
    // gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;
}

/* SOURCE
    "Efficient ray casting of volumetric images using distance maps for empty space skipping"
    https://link.springer.com/content/pdf/10.1007/s41095-019-0155-y.pdf
*/
