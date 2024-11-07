#ifndef LINEAR_ROOTS
#define LINEAR_ROOTS

// coeff[0] + coeff[1] * t
float linear_roots(in vec2 coeff, out int num_roots) 
{
    // If it's constant ( (coeff.y close to 0), check if it's solvable (both coefficients are close to 0)
    if (abs(coeff.y) < PICO_TOLERANCE) {
        num_roots = 0; // if constant is zero, set num_roots (-1.0), otherwise (0.0)
        return 0.0; // For constant case, the root is undefined or any value can work, so we return 0.0 as a placeholder
    }
    
    // For linear equation, compute the root
    num_roots = 1; 
    return -coeff.x / coeff.y;
}

// coeff[0] + coeff[1] * t
float linear_roots(in vec2 coeff) 
{    
    // If it's constant (coeff.y close to 0) return zero
    if (abs(coeff.y) < PICO_TOLERANCE) return 0.0;
    
    // For linear equation, it's solvable and compute the root
    return -coeff.x / coeff.y;
}

#endif // LINEAR_ROOTS
