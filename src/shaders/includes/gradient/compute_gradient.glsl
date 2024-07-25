#include ../gradient/gradient_sobel8.glsl;
#include ../gradient/gradient_central.glsl;
#include ../gradient/gradient_tetrahedron.glsl;

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
vec3 compute_gradient
(
    in uniforms_gradient u_gradient, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    inout float ray_sample, 
    out float ray_gradient
)
{    
    switch (u_gradient.method)
    {
        case 1: 
            return gradient_sobel8(u_gradient, u_volume, u_sampler, ray_position, ray_sample, ray_gradient);
        case 2: 
            return gradient_central(u_gradient, u_volume, u_sampler, ray_position, ray_sample, ray_gradient);
        case 3:  
            return gradient_tetrahedron(u_gradient, u_volume, u_sampler, ray_position, ray_sample, ray_gradient); 
    }
}

// For visual debug
// gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
// gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;