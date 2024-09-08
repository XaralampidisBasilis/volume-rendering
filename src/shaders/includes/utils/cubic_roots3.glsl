// https://momentsingraphics.de/CubicRoots.html#_Blinn07b
// coefficient[0] * x^0 + ... + coefficient[3] * x^3

// Solves a cubic equation only when we have 3 real roots, given the coefficients: 
// coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3
// based on the paper https://courses.cs.washington.edu/courses/cse590b/13au/lecture_notes/solvecubic_p5.pdf
vec3 cubic_roots3(vec4 coefficient)
{
    // Normalize the polynomial
    coefficient.xyz /= coefficient.w;
    
    // Divide middle coefficients by three eq(0.1)
    coefficient.yz /= 3.0;
    
    // Compute the Hessian and the discriminant eq(0.4) and eq(0.7)
    vec3 delta = vec3(
        coefficient.y - coefficient.z * coefficient.z, // mad(-Coefficient.z, Coefficient.z, Coefficient.y)
        coefficient.x - coefficient.y * coefficient.z, // mad(-Coefficient.y, Coefficient.z, Coefficient.x)
        dot(vec2(coefficient.z, -coefficient.y), coefficient.xy)
    );
    
    float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy);
    
    // Compute coefficients of the depressed cubic eq(0.16)
    // depressed[0] + depressed[1] * x + x^3 (third is zero, fourth is one)
    vec2 depressed = vec2(
        delta.y - 2.0 * coefficient.z * delta.x, // mad(-2.0f * Coefficient.z, Delta.x, Delta.y)
        delta.x
    );
    
    // Take the cubic root of a normalized complex number (0.14)    
    float theta = atan(sqrt(discriminant), -depressed.x) / 3.0;
    vec2 cubic_root = vec2(cos(theta), sin(theta));
    
    // Compute the three roots, scale appropriately eq(0.14)
    vec3 roots3 = vec3(
        cubic_root.x,
        dot(vec2(-0.5, -0.5 * sqrt(3.0)), cubic_root),
        dot(vec2(-0.5, 0.5 * sqrt(3.0)), cubic_root)
    );
    
    // revert the depression transform eq(0.2) and eq(0.16)
    roots3 = 2.0 * sqrt(-depressed.y) * roots3 - coefficient.z;
    
    return roots3;
}
