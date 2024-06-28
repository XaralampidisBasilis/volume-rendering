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
 * @param normal: Output vector where the gradient will be stored
 * @param value_max: Output float where the maximum value of the sampled points will be stored
 */
vec3 gradient(in gradient_uniforms u_gradient, in volume_uniforms u_volume, in sampler3D sampler_volume, in vec3 hit_position, inout float intensity_max)
{
    
    intensity_max = 0.0;

    vec3 grad_step = u_volume.voxel / u_gradient.resolution;

    switch (u_gradient.method)
    {
        case 1: 
            return sobel(sampler_volume, grad_step, hit_position, intensity_max);
        case 2: 
            return central(sampler_volume, grad_step, hit_position, intensity_max);
        case 3:  
            return tetrahedron(sampler_volume, grad_step, hit_position, intensity_max); 
        default:
            return vec3(0.0, 0.0, 0.0);
    }

}

// For visual debug
// gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
// gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;