
// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2
// https://www.wikiwand.com/en/articles/Lagrange_polynomial
vec3 lagrange_coefficients(in highp vec3 t, in highp vec3 f)
{
    // Small epsilon to prevent division by near-zero values, ensuring numerical stability
    highp float epsilon = 1e-6;

    // Compute the cross differences 
    highp vec3 dt = t.yzx - t.zxy;
    highp vec3 dt2 = - dt.yzx * dt.zxy;

    // Compute the inverse of the cross difference product but avoid division by very small values using epsilon
    highp vec3 inv_dt2 = mix(vec3(epsilon), 1.0 / dt2, step(epsilon, abs(dt2)));
    highp vec3 tf = inv_dt2 * f;

    highp vec3 coeff = vec3(
        dot(t.yzx * t.zxy, tf),
        dot(t.yzx + t.zxy, -tf),
        dot(vec3(1.0), tf)
    );

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

// depricated
// returns quadratic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2
// https://www.wikiwand.com/en/articles/Lagrange_polynomial
// vec3 lagrange_coefficients(in vec3 t, in vec3 f)
// {
//     vec3 t2 = t * t;
//     mat3 A = mat3(vec3(1.0), t, t2);
//     vec3 coeff = inverse(A) * f;
    
//     return coeff;
// }


