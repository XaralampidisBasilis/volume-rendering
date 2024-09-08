// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2
// https://www.wikiwand.com/en/articles/Lagrange_polynomial
vec3 lagrange_coefficients(in vec3 t, in vec3 f)
{
    vec3 t2 = t * t;
    mat3 A = mat3(vec3(1.0), t, t2);
    vec3 coeff = inverse(A) * f;
    
    return coeff;
}

// case of uniform unit interval t = vec2(0.0, 0.5, 1.0)
vec3 lagrange_coefficients(in vec3 f)
{
    vec3 coeff = vec3(
        f.x,
        dot(f, vec3(-3.0, 4.0, -1.0)),
        dot(f, vec3(2.0, 3.0, -4.0))
    );

    return coeff;
}
