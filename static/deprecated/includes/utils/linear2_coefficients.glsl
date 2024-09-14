// https://www.wikiwand.com/en/articles/Lagrange_polynomial
// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2
// numerically stable solution
vec2 linear2_coefficients(in vec2 t, in vec2 f)
{
    // small epsilon to avoid division by near-zero
    const float epsilon = 1e-6;

    // cross differences
    vec2 t_diff = t.xy - t.yx;

    // avoid division by small values by enforcing a minimum threshold
    t_diff = max(abs(t_diff), epsilon) * ssign(t_diff);

    // matrix-vector multiplication with f_weighted
    mat2 t_matrix = mat2(-t.yx, vec2(1.0));
    vec2 f_weighted = f / t_diff; 
    
    // compute and return coefficients
    vec2 coeff = f_weighted * t_matrix; 
    // gl_FragColor = vec4(vec3(any(isinf(coeff)), 0.0, any(isnan(coeff))), 1.0); 

    return coeff;
}

// depricated
// returns linear polynomial coefficients in the form:
// coeff[0] + coeff[1] * t 
// vec2 linear2_coefficients(in vec2 t, in vec2 f)
// {
//     mat3 A = mat3(vec3(1.0), t);
//     vec2 coeff = inverse(A) * f;
    
//     return coeff;
// }


