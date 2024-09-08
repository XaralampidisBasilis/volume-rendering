// returns cubic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// https://www.wikiwand.com/en/articles/Hermite_interpolation
vec4 hermite_coefficients(in vec2 t, in vec2 f, in vec2 f_prime)
{
    vec2 t2 = t * t;
    vec2 t3 = t2 * t;
    vec4 b = vec4(f, f_prime);
    mat4 A = mat4(
        vec4(vec2(1.0), vec2(0.0)),
        vec4(t, vec2(1.0)),
        vec4(t2, 2.0 * t),
        vec4(t3, 3.0 * t2)
    );

    vec4 coeff = inverse(A) * b;
    return coeff;
}

// case of unit interval t = vec2(0.0, 1.0)
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
vec4 hermite_coefficients(in vec2 f, in vec2 f_prime)
{
    vec4 b = vec4(f, f_prime);
    vec4 coeff = vec4(
        b.x,
        b.z,
        dot(b, vec4(-3.0, 3.0, -2.0, -1.0)),
        dot(b, vec4(2.0, -2.0, 1.0, 1.0))
    );

    return coeff;
}
