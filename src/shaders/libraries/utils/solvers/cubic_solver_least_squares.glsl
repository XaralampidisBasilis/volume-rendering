// Based on Blinn's paper (https://courses.cs.washington.edu/courses/cse590b/13au/lecture_notes/solvecubic_p5.pdf)
// Article by Christoph Peters (https://momentsingraphics.de/CubicRoots.html#_Blinn07b)
// Shadertoy example (// https://www.shadertoy.com/view/7tBGzK)
// Solves a cubic equation given the coefficients: coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3
#ifndef CUBIC_SOLVER_LEAST_SQUARES
#define CUBIC_SOLVER_LEAST_SQUARES

#ifndef POLYNOMIAL_ROOTS
#include "./polynomial_roots"
#endif

void cubic_solver_least_squares(out float roots[7], in vec4 coeffs, float value, float start, float end)
{
    // normalize cubic equation coeffs.w * t^3 + coeffs.z * t^2 + coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;

    // normalize cubic coefficients
    coeffs /= coeffs.w;
    coeffs.xz /= 2.0;

    // compute coeffs of square error derivative 
    float poly_coeffs[7] = float[7] (
        coeffs.x * coeffs.y,
        2.0 * coeffs.y * coeffs.y + coeffs.x * coeffs.z,
        3.0 * coeffs.x + 3.0 * coeffs.y * coeffs.z,
        coeffs.z * coeffs.z + 8.0 * coeffs.y,
        5.0 * coeffs.z,
        6.0,
        0.0
    );

    // solve quintic to find roots
    find_roots(roots, poly_coeffs, start, end);
}

#endif






