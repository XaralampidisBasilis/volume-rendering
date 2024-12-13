// https://www.wikiwand.com/en/articles/Lagrange_polynomial
// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// numerically stable solution

#ifndef LAGRANGE_CUBIC_COEFFICIENTS
#define LAGRANGE_CUBIC_COEFFICIENTS

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef PROD
#include "../prod"
#endif
#ifndef MAXABS
#include "../maxabs"
#endif
#ifndef LINSOLVE
#include "../solvers/linsolve"
#endif


vec4 lagrange_cubic_coefficients(in vec4 t, in vec4 f) 
{
    // cross differences products
    vec4 t_cross_prod = vec4(
        prod(t.xxx - t.yzw),
        prod(t.yyy - t.xzw),
        prod(t.zzz - t.xyw),
        prod(t.www - t.xyz)
    );

    // partial products
    vec4 t_part_prod = vec4(
        prod(t.yzw),
        prod(t.xzw),
        prod(t.xyw),
        prod(t.xyz)
    );

    // mixed sums of double products
    vec4 t_mixed_sum = vec4(
        sum(t.yzw * t.zwy),
        sum(t.xzw * t.zwx),
        sum(t.xyw * t.ywx),
        sum(t.xyz * t.yzx)
    );

    // sum of three components
    vec4 t_comp_sum = vec4(
        sum(t.yzw),
        sum(t.xzw),
        sum(t.xyw),
        sum(t.xyz)
    );

    // matrix-vector multiplication with f_weighted
    mat4 t_matrix = mat4(-t_part_prod, t_mixed_sum, -t_comp_sum, vec4(1.0));
    vec4 f_weighted = f / maxabs(t_cross_prod, MICRO_TOLERANCE); 
    
    // compute and return coefficients
    vec4 coeff = f_weighted * t_matrix; 
    // gl_FragColor = vec4(vec3(any(isinf(coeff)), 0.0, any(isnan(coeff))), 1.0);

    return coeff;
}

// vec4 lagrange_cubic_coefficients(in vec4 t, in vec4 f)
// {
//     vec3 t2 = t * t;
//     vec3 t3 = t2 * t;
//     mat3 A = mat4(vec3(1.0), t, t2, t3);
//     vec3 coeff = linsolve(A, f);
    
//     return coeff;
// }

#endif 
