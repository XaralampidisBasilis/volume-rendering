#include ../utils/sample_intensity.glsl;

/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using the Sobel operator.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param pos: Position in the 3D texture to calculate the gradient
 * @param step: Step vector for sampling the 3D texture
 
 * @param grad: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec3 sobel(sampler3D volume_data, vec3 position, vec3 voxel_step, out float value_max)
{
    // Define offsets for the 8 neighboring points
    vec3 offset[8] = vec3[8](
        vec3(+voxel_step.x, +voxel_step.y, +voxel_step.z), // Right Top Near
        vec3(+voxel_step.x, +voxel_step.y, -voxel_step.z), // Right Top Far
        vec3(+voxel_step.x, -voxel_step.y, +voxel_step.z), // Right Bottom Near
        vec3(+voxel_step.x, -voxel_step.y, -voxel_step.z), // Right Bottom Far
        vec3(-voxel_step.x, +voxel_step.y, +voxel_step.z), // Left Top Near
        vec3(-voxel_step.x, +voxel_step.y, -voxel_step.z), // Left Top Far
        vec3(-voxel_step.x, -voxel_step.y, +voxel_step.z), // Left Bottom Near
        vec3(-voxel_step.x, -voxel_step.y, -voxel_step.z)  // Left Bottom Far
    );

    // Sample the values at the neighboring points
    float values[8];
    for (int i = 0; i < 8; i++)
    {
        values[i] = sample_intensity(volume_data, position + offset[i]);
    }

    // Calculate the gradient using the Sobel operator
    vec3 grad = vec3(
    values[4] + values[5] + values[6] + values[7] - values[0] - values[1] - values[2] - values[3],
    values[2] + values[3] + values[6] + values[7] - values[0] - values[1] - values[4] - values[5],
    values[1] + values[3] + values[5] + values[7] - values[0] - values[2] - values[4] - values[6]
    );
    grad = normalize(grad);

    // Find the maximum value among the sampled points
    value_max = max(
        max(
            max(values[0], values[1]), 
            max(values[2], values[3])), 
        max(
            max(values[4], values[5]), 
            max(values[6], values[7])
        )
    );

    return grad;

    // For visual debug (uncomment if needed)
    // gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
    // gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;
}
