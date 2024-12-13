
#ifndef LINEAR_SOLVER
#define LINEAR_SOLVER

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

float linear_solver(in vec2 coeffs, float value)
{
    // set default root
    float default_root = -1.0;

    // normalize equation coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;

    // compute normalized linear coefficients 
    float linear_coeff = coeffs.x / coeffs.y;

    // compute linear root
    float linear_root = - linear_coeff;
   
    // linear solutions
    return (abs(coeffs.y) < MICRO_TOLERANCE) ? default_root : linear_root;
}

#endif






