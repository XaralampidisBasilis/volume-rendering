#ifndef COMPUTE_GRADIENT
#define COMPUTE_GRADIENT

#if GRADIENTS_METHOD == 0
#if INTERPOLATION_METHOD == 0
#include "./compute_gradient/compute_gradient_trilinear_analytic"
#endif

#if INTERPOLATION_METHOD == 1
#include "./compute_gradient/compute_gradient_tricubic_analytic"
#endif

#endif

#if GRADIENTS_METHOD == 1
#include "./compute_gradient/compute_gradient_trilinear_sobel"
#endif

#if GRADIENTS_METHOD == 2
#include "./compute_gradient/compute_gradient_triquadratic_bspline"
#endif

vec3 compute_gradient(in vec3 coords)
{
    #if GRADIENTS_METHOD == 0
    #if INTERPOLATION_METHOD == 0
    return compute_gradient_trilinear_analytic(coords);
    
    #elif INTERPOLATION_METHOD == 1
    return compute_gradient_tricubic_analytic(coords);
    #endif

    #elif GRADIENTS_METHOD == 1
    return compute_gradient_trilinear_sobel(coords);

    #elif GRADIENTS_METHOD == 2
    return compute_gradient_triquadratic_bspline(coords);

    #else
    return vec3(0.0); 
    #endif
}

vec3 compute_gradient(in vec3 coords, out mat3 hessian)
{
    #if GRADIENTS_METHOD == 0
    #if INTERPOLATION_METHOD == 0
    return compute_gradient_trilinear_analytic(coords, hessian);
            
    #elif INTERPOLATION_METHOD == 1
    return compute_gradient_tricubic_analytic(coords, hessian);
    #endif

    #elif GRADIENTS_METHOD == 1
    return compute_gradient_trilinear_sobel(coords, hessian);

    #elif GRADIENTS_METHOD == 2
    return compute_gradient_triquadratic_bspline(coords, hessian);

    #else
    hessian = mat3(0.0);
    return vec3(0.0); 
    #endif
}

#endif 
