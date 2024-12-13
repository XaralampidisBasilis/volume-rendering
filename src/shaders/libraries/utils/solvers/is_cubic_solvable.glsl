#ifndef IS_CUBIC_SOLVABLE
#define IS_CUBIC_SOLVABLE

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef QUADRATIC_SOLVER
#include "./quadratic_solver"
#endif
#ifndef CUBIC_POWS
#include "./cubic_pows"
#endif

// compute cubic derivative factors
const vec3 cubic_derivative_factors = vec3(1.0, 2.0, 3.0);

bool is_cubic_solvable(in vec4 coeffs, in float value, in float start, in float end)
{
    // normalize cubic equation coeffs.w * t^3 + coeffs.z * t^2 + coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;

    // compute the cubic at the boundary values
    vec2 boundary_values = vec2
    (
        dot(coeffs, cubic_pows(start)),
        dot(coeffs, cubic_pows(end))
    );

    // compute the derivative of cubic and solve for the extrema values
    vec3 quadratic_coeffs = coeffs.yzw * cubic_derivative_factors;
    vec2 quadratic_roots = quadratic_solver(quadratic_coeffs, 0.0, start);

    // compute the cubic at the extrema values
    vec2 extrema_values = vec2
    (
        dot(coeffs, cubic_pows(quadratic_roots.x)),
        dot(coeffs, cubic_pows(quadratic_roots.y))
    );
    
    // check if the extrema are within the interval and evaluate the cubic at those points
    bvec2 is_inside = greaterThan(inside_open(start, end, quadratic_roots), vec2(MICRO_TOLERANCE));

    // check solution based on intermediate value theorem
    bool is_solvable = (boundary_values.x * boundary_values.y <= MICRO_TOLERANCE);

    // check solution based on the first extrema value inside the interval
    is_solvable = is_solvable || 

        (is_inside.x && ((extrema_values.x * boundary_values.x < MICRO_TOLERANCE) ||
                         (extrema_values.x * boundary_values.y < MICRO_TOLERANCE) || 
                         (abs(extrema_values.x) < MICRO_TOLERANCE))) ||

        (is_inside.y && ((extrema_values.y * boundary_values.x < MICRO_TOLERANCE) ||
                         (extrema_values.y * boundary_values.y < MICRO_TOLERANCE) || 
                         (abs(extrema_values.y) < MICRO_TOLERANCE))); 

    // return result
    return is_solvable;
}

#endif
