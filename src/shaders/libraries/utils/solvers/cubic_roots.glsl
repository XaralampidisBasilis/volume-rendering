// Based on Blinn's paper (https://courses.cs.washington.edu/courses/cse590b/13au/lecture_notes/solvecubic_p5.pdf)
// Article by Christoph Peters (https://momentsingraphics.de/CubicRoots.html#_Blinn07b)
// Shadertoy example (// https://www.shadertoy.com/view/7tBGzK)
// Solves a cubic equation given the coefficients: coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3

#ifndef CUBIC_ROOTS
#define CUBIC_ROOTS

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef QUADRATIC_ROOTS
#include "./quadratic_roots"
#endif
#ifndef CBRT
#include "./cbrt"
#endif


/**
 * Determines if a cubic equation can be approximated as a quadratic equation.
 *
 * This function calculates whether the cubic term of a given cubic polynomial 
 * contributes negligibly to the overall solution, allowing the polynomial 
 * to be reduced to a quadratic form. It achieves this by estimating the 
 * cubic term's error and comparing it against a small tolerance value.
 *
 * The cubic polynomial is represented as:
 *     coeff[0] + coeff[1] * x + coeff[2] * x^2 + coeff[3] * x^3 = 0
 *
 * @param coeff  A vec4 containing the coefficients of the cubic polynomial:
 *               coeff.x = constant term,
 *               coeff.y = linear term,
 *               coeff.z = quadratic term,
 *               coeff.w = cubic term.
 *
 * @return A float value indicating whether the cubic term is negligible:
 *         Returns 1.0 (true) if the cubic term's error is below a predefined tolerance,
 *         Returns 0.0 (false) otherwise.
 */
bool is_quadratic(in vec4 coeff)
{
    vec2 c = coeff.xy / (coeff.z + MICRO_TOLERANCE);
    c.y /= 2.0;

    float t = abs(c.y) + sqrt(abs(c.y * c.y - c.x));
    float cubic_error = coeff.w * cbrt(t);

    return abs(cubic_error) < MICRO_TOLERANCE;
}

vec3 cubic_roots(in vec4 coeff, out int num_roots)
{
    float root12; vec2 roots2; vec3 roots3;

    if (abs(coeff.w) < MICRO_TOLERANCE) 
    {
        roots2 = quadratic_roots(coeff.xyz, num_roots);

        return roots2.xyy;
    }

    // normalize coefficients
    coeff.xyz /= coeff.w;
    coeff.yz /= 3.0;

    // compute hessian coeeficents eq(0.4)
    vec3 delta = vec3(
        coeff.y - coeff.z * coeff.z,                          // δ1 = coeff.w * coeff.y - coeff.z^2
        coeff.x - coeff.y * coeff.z,                          // δ2 = coeff.w * coeff.x - coeff.y * coeff.z
        dot(vec2(coeff.z, -coeff.y), coeff.xy)    // δ3 = coeff.z * coeff.x - coeff.y * coeff.x
    );

    // compute discriminant eq(0.7)
    float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy); // Δ = δ1 * δ3 - δ2^2
    float sqrt_discrim = sqrt(abs(discriminant));

    // compute depressed cubic eq(0.16) 
    // coefficients depressed[0] + depressed[1] * x + x^3
    vec2 coeff_depressed = vec2(delta.y - 2.0 * coeff.z * delta.x, delta.x);

    // compute real root using cubic root formula for one real and two complex roots eq(0.15)
    if (discriminant < 0.0) 
    {
        num_roots = 1;
        root12 = cbrt((-coeff_depressed.x + sqrt_discrim) * 0.5) 
               + cbrt((-coeff_depressed.x - sqrt_discrim) * 0.5)
               - coeff.z;

        return vec3(root12);
    }

    // compute cubic roots using complex number formula eq(0.14)  
    float theta = atan(sqrt_discrim, -coeff_depressed.x) / 3.0;
    vec2 cubic_root = vec2(cos(theta), sin(theta));
   
    // compute three roots via rotation, applying complex root formula eq(0.14)
    roots3 = vec3(
        cubic_root.x,                                                   // First root
        dot(vec2(-0.5, -0.5 * sqrt(3.0)), cubic_root),   // Second root (rotated by 120 degrees)
        dot(vec2(-0.5,  0.5 * sqrt(3.0)), cubic_root)     // Third root (rotated by -120 degrees)
    );

    // revert transformation and sort the three real roots eq(0.2) and eq(0.16)
    roots3 = sqrt(max(0.0, -coeff_depressed.y)) * roots3 * 2.0 - coeff.z; 
    num_roots = 3 - 2 * int(discriminant < MICRO_TOLERANCE);

    return roots3;
}


vec3 cubic_roots(in vec4 coeff)
{
    float root12; vec2 roots2; vec3 roots3;

    // check if quadratic
    if (abs(coeff.w) < MICRO_TOLERANCE) 
    {
        roots2 = quadratic_roots(coeff.xyz);

        return roots2.xyy;
    }

    // normalize coefficients
    coeff.xyz /= coeff.w;
    coeff.yz /= 3.0;

    // compute hessian coeeficents eq(0.4)
    vec3 delta = vec3(
        coeff.y - coeff.z * coeff.z,                          // δ1 = coeff.w * coeff.y - coeff.z^2
        coeff.x - coeff.y * coeff.z,                          // δ2 = coeff.w * coeff.x - coeff.y * coeff.z
        dot(vec2(coeff.z, -coeff.y), coeff.xy)    // δ3 = coeff.z * coeff.x - coeff.y * coeff.x
    );

    // compute discriminant eq(0.7)
    float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy); // Δ = δ1 * δ3 - δ2^2
    float sqrt_discrim = sqrt(abs(discriminant));

    // compute depressed cubic eq(0.16), coefficients depressed[0] + depressed[1] * x + x^3
    vec2 coeff_depressed = vec2(delta.y - 2.0 * coeff.z * delta.x, delta.x);
    
    // compute cubic roots using complex number formula eq(0.14)  
    float theta = atan(sqrt_discrim, -coeff_depressed.x) / 3.0;
    vec2 cubic_root = vec2(cos(theta), sin(theta));

    // compute real root using cubic root formula for one real and two complex roots eq(0.15)
    if (discriminant < MICRO_TOLERANCE) 
    {
        root12 = cbrt((-coeff_depressed.x + sqrt_discrim) * 0.5) 
               + cbrt((-coeff_depressed.x - sqrt_discrim) * 0.5)
               - coeff.z;

        return vec3(root12);
    }
   
    // compute three roots via rotation, applying complex root formula eq(0.14)
    roots3 = vec3(
        cubic_root.x,                                                   // First root
        dot(vec2(-0.5, -0.5 * sqrt(3.0)), cubic_root),   // Second root (rotated by 120 degrees)
        dot(vec2(-0.5,  0.5 * sqrt(3.0)), cubic_root)     // Third root (rotated by -120 degrees)
    );

    // revert transformation and sort the three real roots eq(0.2) and eq(0.16)
    roots3 = sqrt(max(0.0, -coeff_depressed.y)) * roots3 * 2.0 - coeff.z; 

    return roots3;
}

#endif // CUBIC_ROOTS






