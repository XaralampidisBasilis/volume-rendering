// https://www.wikiwand.com/en/articles/Lagrange_polynomial
// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2
// numerically stable solution

#ifndef LAGRANGE_QUADRATIC_COEFFICIENTS
#define LAGRANGE_QUADRATIC_COEFFICIENTS

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef PROD
#include "../prod"
#endif
#ifndef MAXABS
#include "../maxabs"
#endif

vec3 lagrange_quadratic_coefficients(in vec3 t, in vec3 f)
{
    // cross differences products
    vec3 t_cross_prod = vec3(
        prod(t.xx - t.yz),
        prod(t.yy - t.xz),
        prod(t.zz - t.xy)
    );

    // partial products
    vec3 t_part_prod = vec3(
        prod(t.yz),
        prod(t.xz),
        prod(t.xy)
    );

    // sum of two components
    vec3 t_comp_sum = vec3(
        sum(t.yz),
        sum(t.xz),
        sum(t.xy)
    );

    // matrix-vector multiplication with f_weighted
    mat3 t_matrix = mat3(t_part_prod, - t_comp_sum, vec3(1.0));
    vec3 f_weighted = f / maxabs(t_cross_prod, MICRO_TOLERANCE); 
    
    // compute and return coefficients
    vec3 coeff = f_weighted * t_matrix; 
    // gl_FragColor = vec4(vec3(any(isinf(coeff)), 0.0, any(isnan(coeff))), 1.0); 

    return coeff;
}

// vec3 lagrange_quadratic_coefficients(in vec3 t, in vec3 f)
// {
//     vec3 t2 = t * t;
//     mat3 A = mat3(vec3(1.0), t, t2);
//     vec3 coeff = inverse(A) * f;
    
//     return coeff;
// }

#endif // LAGRANGE_QUADRATIC_COEFFICIENTS