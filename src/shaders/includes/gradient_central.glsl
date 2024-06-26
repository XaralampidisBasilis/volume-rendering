/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using the central differences approximation.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param pos: Position in the 3D texture to calculate the gradient
 * @param step: Step vector for sampling the 3D texture
 
 * @param grad: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec3 gradient_central(sampler3D data, vec3 pos, vec3 step, out float value_max)
{
    vec3 offset[6] = vec3[6](
        vec3(+step.x, 0.0, 0.0), // Right
        vec3(-step.x, 0.0, 0.0), // Left
        vec3(0.0, +step.y, 0.0), // Top
        vec3(0.0, -step.y, 0.0), // Bottom
        vec3(0.0, 0.0, +step.z), // Near
        vec3(0.0, 0.0, -step.z)  // Far
    );

    float values[6];
    for (int i = 0; i < 6; i++)
    {
        values[i] = texture(data, pos + offset[i]).r;
    }

    vec3 grad = vec3(
        values[1] - values[0],
        values[3] - values[2],
        values[5] - values[4]
    );
    grad = normalize(grad);

    value_max = max(
        max(values[0], values[1]), 
        max(
            max(values[2], values[3]), 
            max(values[4], values[5])
        )
    );

    return grad;

    // For visual debug
    // gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
    // gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;
}

/* SOURCE
    Based on interpolated sobel operator, offset needs to be off-grid to work properly
    typical value offset = 0.7 / volume_dimensions, for texel coordinates
    https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
*/