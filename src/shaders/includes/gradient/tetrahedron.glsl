#include ../../utils/sample_intensity.glsl;

/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using the tetrahedron method.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param pos: Position in the 3D texture to calculate the gradient
 * @param step: Step vector for sampling the 3D texture
 
 * @param grad: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec3 tetrahedron(sampler3D volume_data, vec3 position, vec3 voxel_step, out float value_max)
{
    vec3 offset[4] = vec3[4](
        vec3(+voxel_step.x, +voxel_step.y, +voxel_step.z), // Right Top Near
        vec3(+voxel_step.x, -voxel_step.y, -voxel_step.z), // Right Bottom Far
        vec3(-voxel_step.x, +voxel_step.y, -voxel_step.z), // Left Top Far
        vec3(-voxel_step.x, -voxel_step.y, +voxel_step.z)  // Left Bottom Near
    );

    float value[4];
    for (int i = 0; i < 4; i++)
    {
        value[i] = sample_intensity(volume_data, position + offset[i]);
    }

    vec3 grad = vec3(
        value[0] + value[1] - value[2] - value[3],
        value[0] + value[2] - value[1] - value[3],
        value[0] + value[3] - value[1] - value[2]
    );
    grad = normalize(grad);

    value_max = max(
        max(value[0], value[1]), 
        max(value[2], value[3])
    );

    return grad;
    
    // For visual debug
    // gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
    // gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;}
}

/* SOURCE
    "Efficient ray casting of volumetric images using distance maps for empty space skipping"
    https://link.springer.com/content/pdf/10.1007/s41095-019-0155-y.pdf
*/
