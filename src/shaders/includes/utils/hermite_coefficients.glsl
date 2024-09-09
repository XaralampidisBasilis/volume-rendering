
// Function to compute the Hermite coefficients based on time (t), function values (f), and gradients (g)
// returns cubic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// https://www.wikiwand.com/en/articles/Hermite_interpolation
vec4 hermite_coefficients(in highp vec2 t, in highp vec2 f, in highp vec2 g)
{
    // Small epsilon to prevent division by near-zero values, ensuring numerical stability
    highp float epsilon = 1e-8;

    // Compute the difference between the two time values (t0 - t1)
    highp float dt = t.x - t.y;
    highp float dt2 = dt * dt;
    highp float dt3 = dt2 * dt;

    // Compute the inverse of dt^3, but avoid division by very small values using epsilon
    highp float inv_dt2 = mix(epsilon, 1.0 / dt2, step(epsilon, abs(dt2)));
    highp float inv_dt3 = mix(epsilon, 1.0 / dt3, step(epsilon, abs(dt3)));

    // Combine function values and gradients into a 4D vector 
    highp vec4 tfg = vec4(f * inv_dt3, g * inv_dt2);

    // Predefined vectors for the Hermite basis functions
    highp vec4 u0 = vec4(-1.0, 1.0, 0.0, 0.0); 
    highp vec4 u1 = vec4(0.0, 0.0, 1.0, 1.0);  
    highp vec4 u2 = u0 * 3.0 + u1;

    // Calculate the Hermite coefficients using dot products between fg and transformed basis vectors
    highp vec4 coeff = vec4(
        dot(t.yxyx * u0 - t.xyxy * u2, tfg * t.yxyx * t.yxyx),  
        dot(t.yxyx * u1 + t.xyxy * u2 * 2.0, tfg * t.yxyx),     
        dot(t.yxyx * (u2 + u1) + t.xyxy * u2, -tfg),           
        dot(u0 * 2.0 + u1, tfg)                                        
    );

    // Scale the result by the inverse of dt^3 and return the coefficients
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

// DEPRICATED 
// NUMERICALY UNSTABLE 

// returns cubic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// https://www.wikiwand.com/en/articles/Hermite_interpolation
// vec4 hermite_coefficients(in vec2 t, in vec2 f, in vec2 f_prime)
// {
//     vec2 t2 = t * t;
//     vec2 t3 = t2 * t;
//     vec4 b = vec4(f, f_prime);
//     mat4 A = mat4(
//         vec4(vec2(1.0), vec2(0.0)),
//         vec4(t, vec2(1.0)),
//         vec4(t2, 2.0 * t),
//         vec4(t3, 3.0 * t2)
//     );

//     vec4 coeff = inverse(A) * b;
//     return coeff;
// }

