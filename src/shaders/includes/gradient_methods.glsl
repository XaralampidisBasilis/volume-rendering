uniform int u_gradient_method;
uniform float u_gradient_resolution;

#include ./gradient_sobel.glsl;
#include ./gradient_central.glsl;
#include ./gradient_tetrahedron.glsl;

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
vec3 gradient_methods(sampler3D data, vec3 pos, vec3 step, out float value_max)
{
    step /= u_gradient_resolution;

    switch (u_gradient_method)
    {
        case 1:
            return gradient_sobel(data, pos, step, value_max);

        case 2:
            return gradient_central(data, pos, step, value_max);

        case 3:
            return gradient_tetrahedron(data, pos, step, value_max); 
            
        default:
            value_max = 0.0;
            return vec3(0.0);
    }
}