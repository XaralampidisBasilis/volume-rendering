#ifndef QUADRATIC_ROOTS
#define QUADRATIC_ROOTS

// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(in vec3 coeff, out int num_roots) 
{
    // If linear return early
    float error = pow2(coeff.z / coeff.y) * coeff.x;
    if (abs(error) < PICO_TOL) return vec2(linear_roots(coeff.xy, num_roots));

    // Normalize coefficients (divide x and y by z)
    coeff.xy /= coeff.z;
    coeff.y /= 2.0;

    // Calculate discriminant
    float discriminant = coeff.y * coeff.y - coeff.x;

    // If the discriminant is negative, there's no real solution
    if (discriminant < 0.0) {
        num_roots = 0; 
        return vec2(0.0); // Not solvable in the real number system, return a default root (0.0)
    }
       
    // Calculate the roots using the quadratic formula
    num_roots = 2 - int(discriminant < PICO_TOL);
    return sqrt(discriminant) * vec2(-1.0, 1.0) - coeff.y;;
}

// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(in vec3 coeff) 
{
    // If linear return early
    float error = pow2(coeff.z / coeff.y) * coeff.x;
    if (abs(error) < PICO_TOL) return vec2(linear_roots(coeff.xy));

    // Normalize coefficients (divide x and y by z)
    coeff.xy /= coeff.z;
    coeff.y /= 2.0;

    // Calculate discriminant
    float discriminant = coeff.y * coeff.y - coeff.x;

    // If the discriminant is negative, there's no real solution
    if (discriminant < PICO_TOL)  return vec2(0.0); // Not solvable in the real number system, return a default root (0.0)

    // Return the quadratic roots sorted 
    return sqrt(discriminant) * vec2(-1.0, 1.0) - coeff.y;
}

#endif // QUADRATIC_ROOTS
