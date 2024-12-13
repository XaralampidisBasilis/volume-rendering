#ifndef IS_QUADRATIC_SOLVABLE
#define IS_QUADRATIC_SOLVABLE

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef LINEAR_SOLVER
#include "./linear_solver"
#endif
#ifndef QUADRATIC_POWS
#include "./quadratic_pows"
#endif

// compute quadratic derivative factors
const vec2 quadratic_derivative_factors = vec2(1.0, 2.0);

bool is_quadratic_solvable(in vec3 coeffs, in float value, in float start, in float end)
{
    // normalize quadratic equation coeffs.z * t^2 + coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;

    // compute the quadratic at the boundary values
    vec2 boundary_values = vec2
    (
        dot(coeffs, quadratic_pows(start)),
        dot(coeffs, quadratic_pows(end))
    );

    // compute the derivative of quadratic and solve for the extrema values
    vec2 linear_coeffs = coeffs.yz * quadratic_derivative_factors;
    float linear_root = linear_solver(linear_coeffs, 0.0, start);

    // compute the extrema value
    float extrema_value = dot(coeffs, quadratic_pows(linear_root));
    
    // check if the extrema are within the interval and evaluate the quadratic at those points
    bool is_inside = inside_open(start, end, linear_root) > MICRO_TOLERANCE;

    // check solution based on intermediate value theorem
    bool is_solvable = (boundary_values.x * boundary_values.y <= MICRO_TOLERANCE);

    // check solution based on the extrema values inside the interval
    is_solvable = is_solvable || 

        (is_inside && ((extrema_value * boundary_values.x < MICRO_TOLERANCE) ||
                       (extrema_value * boundary_values.y < MICRO_TOLERANCE) || 
                       (abs(extrema_value) < MICRO_TOLERANCE)));

    // return result
    return is_solvable;
}

#endif
