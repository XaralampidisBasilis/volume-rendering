#include ../gradient/gradient_sobel.glsl;
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
vec3 gradient(
    in uniforms_gradient u_gradient, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_position, 
    inout float ray_sample, 
    out float gradient_magnitude
)
{
    vec3 gradient_step = u_volume.voxel / u_gradient.resolution;
    vec3 gradient_vector = vec3(0.0, 0.0, 0.0);

    float max_sample = ray_sample;

    switch (u_gradient.method)
    {
        case 1: 
            gradient_vector = gradient_sobel(u_sampler.volume, gradient_step, ray_position, max_sample, gradient_magnitude);
            break;
        case 2: 
            gradient_vector = gradient_central(u_sampler.volume, gradient_step, ray_position, max_sample, gradient_magnitude);
            break;
        case 3:  
            gradient_vector =  gradient_tetrahedron(u_sampler.volume, gradient_step, ray_position, max_sample, gradient_magnitude); 
            break;
    }

    ray_sample = mix(ray_sample, max_sample, u_gradient.neighbor);
    return gradient_vector;
}

// For visual debug
// gradient.rgb = (gradient.rgb * 0.5) + 0.5; // transforms the normalized RGB components from the range [-1, 1] to the range [0, 1]
// gradient.a = (abs(gradient.r) + abs(gradient.g) + abs(gradient.b)) * 0.29;