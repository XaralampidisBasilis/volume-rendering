
#ifndef QUADRATIC_SOLVER
#define QUADRATIC_SOLVER

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

vec2 quadratic_solver(in vec3 coeffs, in float value)
{
    // set default roots
    vec2 default_roots = vec2(-1.0);

    // normalize equation coeffs.z * t^2 + coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;


    /* LINEAR */ 

    // compute normalized linear coefficients 
    float linear_coeff = coeffs.x / coeffs.y;

    // compute linear root
    vec2 linear_roots = vec2(- linear_coeff);

    // compute quadratic error resulting from linear root
    // float quadratic_linear_error = coeffs.y * coeffs.z * coeffs.z;


    /* QUADRATIC */ 

    // compute normalized quadratic coefficients 
    vec2 quadratic_coeffs = coeffs.xy / coeffs.z;
    quadratic_coeffs.y /= 2.0;

    // compute quadratic discriminant
    float quadratic_discriminant = quadratic_coeffs.y * quadratic_coeffs.y - quadratic_coeffs.x;
    float sqrt_quadratic_discriminant = sqrt(abs(quadratic_discriminant));

    // compute quadratic roots 
    vec2 quadratic_roots = - quadratic_coeffs.y + vec2(-1.0, 1.0) * sqrt_quadratic_discriminant;


    /* SOLUTIONS */ 
   
    // degenerate linear
    if (abs(coeffs.z) < MICRO_TOLERANCE)
    {
        // linear solutions
        return (abs(coeffs.y) < MICRO_TOLERANCE) ? default_roots : linear_roots;
    }
    else 
    {
        // quadratic solutions
        return (quadratic_discriminant < MICRO_TOLERANCE) ? default_roots : quadratic_roots;
    }

    
}

vec2 quadratic_solver(in vec3 coeffs, in float value, in float flag)
{
    // set default roots
    vec2 default_roots = vec2(flag);

    // normalize equation coeffs.z * t^2 + coeffs.y * t + (coeffs.x - value) = 0
    coeffs.x -= value;


    /* LINEAR */ 

    // compute normalized linear coefficients 
    float linear_coeff = coeffs.x / coeffs.y;

    // compute linear root
    vec2 linear_roots = vec2(- linear_coeff);

    // compute quadratic error resulting from linear root
    // float quadratic_linear_error = coeffs.y * coeffs.z * coeffs.z;


    /* QUADRATIC */ 

    // compute normalized quadratic coefficients 
    vec2 quadratic_coeffs = coeffs.xy / coeffs.z;
    quadratic_coeffs.y /= 2.0;

    // compute quadratic discriminant
    float quadratic_discriminant = quadratic_coeffs.y * quadratic_coeffs.y - quadratic_coeffs.x;
    float sqrt_quadratic_discriminant = sqrt(abs(quadratic_discriminant));

    // compute quadratic roots 
    vec2 quadratic_roots = - quadratic_coeffs.y + vec2(-1.0, 1.0) * sqrt_quadratic_discriminant;


    /* SOLUTIONS */ 
   
    // degenerate linear
    if (abs(coeffs.z) < MICRO_TOLERANCE)
    {
        // linear solutions
        return (abs(coeffs.y) < MICRO_TOLERANCE) ? default_roots : linear_roots;
    }
    else 
    {
        // quadratic solutions
        return (quadratic_discriminant < MICRO_TOLERANCE) ? default_roots : quadratic_roots;
    }

    
}

#endif






