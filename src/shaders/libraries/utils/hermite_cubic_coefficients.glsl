#ifndef HERMITE_CUBIC_COEFFICIENTS
#define HERMITE_CUBIC_COEFFICIENTS

#ifndef MILLI_TOLERANCE
#define MILLI_TOLERANCE 1e-3
#endif

#ifndef LINSOLVE
#include "./linsolve"
#endif

// Function to compute the Hermite coefficients based on time (t), function values (f), and gradients (g)
// returns cubic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// https://www.wikiwand.com/en/articles/Hermite_interpolation
vec4 hermite_cubic_coefficients(in vec2 t, in  vec2 f, in  vec2 g)
{
    // Compute the difference between the two time values (t0 - t1)
    float tolerance = mmax(abs(t)) * MILLI_TOLERANCE;
    float dt = maxabs(t.x - t.y, tolerance);
    float dt2 = dt * dt;
    float dt3 = dt2 * dt;
     
    // Combine function values and gradients into a 4D vector 
    vec4 fg_weighted = vec4(f / dt3, g / dt2);

    // Predefined vectors for the Hermite basis functions
    const vec4 u0 = vec4(-1.0, 1.0, 0.0, 0.0); 
    const vec4 u1 = vec4(0.0, 0.0, 1.0, 1.0);  
    const vec4 u2 = u0 * 3.0 + u1;

    // Calculate the Hermite coefficients using dot products between fg and transformed basis vectors
    vec4 coeff = vec4(
        dot(t.yxyx * u0 - t.xyxy * u2, fg_weighted * t.yxyx * t.yxyx),  
        dot(t.yxyx * u1 + t.xyxy * u2 * 2.0, fg_weighted * t.yxyx),     
        dot(t.yxyx * (u2 + u1) + t.xyxy * u2, -fg_weighted),           
        dot(u0 * 2.0 + u1, fg_weighted)                                        
    );

    // Scale the result by the inverse of dt^3 and return the coefficients
    return coeff;
}

// returns cubic polynomial coefficients in the form:
// coeff[0] + coeff[1] * t + coeff[2] * t^2 + coeff[3] * t^3
// https://www.wikiwand.com/en/articles/Hermite_interpolation   
// vec4 hermite_cubic_coefficients(in vec2 t, in vec2 f, in vec2 g)
// {
//     // define the linear system of equations
//     vec2 t2 = t * t;
//     vec2 t3 = t2 * t;
//     vec4 b = vec4(f, g);
//     mat4 A = mat4(
//         vec4(vec2(1.0), vec2(0.0)),
//         vec4(t, vec2(1.0)),
//         vec4(t2, 2.0 * t),
//         vec4(t3, 3.0 * t2)
//     );
//     vec4 coeffs = linsolve(A, b);
//     return coeffs;
// }

#endif // HERMITE_CUBIC_COEFFICIENTS
