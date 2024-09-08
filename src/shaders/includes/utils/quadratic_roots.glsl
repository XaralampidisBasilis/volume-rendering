#define MAX_FLOAT 1e+38

// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(vec3 coefficient) 
{
    // Step 1: Normalize quadratic equation (coefficient[2] must be 1)
    coefficient = coefficient / coefficient.z;

    // Step 2: Divide the middle coefficient by 2 for further simplification
    coefficient.y /= 2.0;
    
    // Step 2: Calculate discriminant
    float discriminant = coefficient.y * coefficient.y - coefficient.x;
    
    // Step 3: Compute two real roots, applying quadratic formula
    vec2 roots2 = coefficient.y + vec2(-1.0, 1.0) * sqrt(discriminant); 

    // Step 4: Combine roots depending on discriminant
    vec2 roots = mix(vec2(MAX_FLOAT), roots2, step(0.0, discriminant));

    return roots;
}
