#include ../gradient/sobel.glsl;
#include ../gradient/central.glsl;
#include ../gradient/tetrahedron.glsl;

/**
 * Calculates the gradient and maximum value at a given position in a 3D texture using either the 3 following methods.
 *  1. sobel, 2. central differences approximation, 3. tetrachedron method
 *
 * @param data: 3D texture sampler containing intensity data
 * @param pos: Position in the 3D texture to calculate the gradient
 * @param step: Step vector for sampling the 3D texture
 *
 * @param grad: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec3 gradient(gradient_uniforms u_gradient, volume_uniforms u_volume, vec3 position, out float value_max)
{
    value_max = 0.0;
    vec3 voxel_substep = u_volume.voxel / u_gradient.resolution;

    switch (u_gradient.method)
    {
        case 1: return sobel(u_volume.data, position, voxel_substep, value_max);
        case 2: return central(u_volume.data, position, voxel_substep, value_max);
        case 3: return tetrahedron(u_volume.data, position, voxel_substep, value_max); 
        default: return vec3(1.0, 0.0, 0.0); // error gradient
    }
}