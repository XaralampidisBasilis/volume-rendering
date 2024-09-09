// Special cube root to fix GLSL's negative pow() bug
float cbrt(in float x) { return sign(x) * pow(abs(x), 1.0 / 3.0); }

// Solves a cubic equation given the coefficients: 
// coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3
// Based on Blinn's paper (https://courses.cs.washington.edu/courses/cse590b/13au/lecture_notes/solvecubic_p5.pdf)
// Article by Christoph Peters (https://momentsingraphics.de/CubicRoots.html#_Blinn07b)
// vec3 cubic_roots(in highp vec4 coeffs)
// {
//        // Step 1: Normalize the cubic equation (coefficient[3] must be 1)
//     coeffs.xyz /= coeffs.w;
    
//     // Step 2: Divide the middle coefficients by 3 for further simplifications eq(0.1)
//     coeffs.yz /= 3.0;

//     // Step 3: Compute the Hessian coeeficents of the quadratic eq(0.4)
//     highp vec3 delta = vec3(
//         coeffs.y - coeffs.z * coeffs.z,                          // δ1 = coeff.w * coeff.y - coeff.z^2
//         coeffs.x - coeffs.y * coeffs.z,                          // δ2 = coeff.w * coeff.x - coeff.y * coeff.z
//         dot(vec2(coeffs.z, -coeffs.y), coeffs.xy)    // δ3 = coeff.z * coeff.x - coeff.y * coeff.x
//     );
    
//     // Step 4: Calculate discriminant and its square root eq(0.7)
//     highp float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy); // Δ = δ1 * δ3 - δ2^2
//     highp float sqrt_discriminant = sqrt(abs(discriminant));

//     // Step 5: Compute coefficients of the depressed cubic eq(0.16),
//     // depressed[0] + depressed[1] * x + x^3 (third coefficient is zero, fourth is one)
//     highp vec2 depressed = vec2(
//         delta.y - 2.0 * coeffs.z * delta.x, // Depressed cubic coefficient calculation
//         delta.x
//     );
    
//     // Step 6: Calculate cubic roots using complex number formula eq(0.14)  
//     highp float theta = atan(sqrt_discriminant, -depressed.x) / 3.0; //  gl_FragColor = vec4(vec3(isnan(theta), 0.0, isinf(theta)), 1.0);
//     highp vec2 cubic_root = vec2(cos(theta), sin(theta));

//     // Step 7: Compute real root using cubic root formula for one real and two complex roots eq(0.15)
//     highp float roots21 = 
//         cbrt((-depressed.x + sqrt_discriminant) * 0.5) // gl_FragColor = vec4(vec3(isnan(root21)), 1.0);
//              + cbrt((-depressed.x - sqrt_discriminant) * 0.5);

//     // Step 8: Compute three roots via rotation, applying complex root formula eq(0.14)
//     highp vec3 roots3 = vec3(
//         cubic_root.x,                                                   // First root
//         dot(vec2(-0.5, -0.5 * sqrt(3.0)), cubic_root),   // Second root (rotated by 120 degrees)
//         dot(vec2(-0.5, 0.5 * sqrt(3.0)), cubic_root)     // Third root (rotated by -120 degrees)
//     );

//     // Step 9: Sort and scale the three roots
//     roots3 = 2.0 * sqrt(max(-depressed.y, 1e-6)) * roots3; // gl_FragColor = vec4(vec3(any(isnan(roots3)), 0.0, any(isinf(roots3))), 1.0);
//     roots3 = sort(roots3);     

//     // Step 10: Combine real and complex roots depending on discriminant, and revert transformation eq(0.2) and eq(0.16)
//     highp vec3 roots = -coeffs.z + mix(vec3(roots21), roots3, step(0.0, discriminant));
//     // gl_FragColor = vec4(vec3(any(isnan(roots)), 0.0, any(isinf(roots))), 1.0);

//     return roots;
// }

vec3 cubic_roots(in vec4 coeff)
{
    const float degenerate = -1.0;
    const float epsilon = 1e-6;

    // check if cubic
    float is_cubic = step(epsilon, abs(coeff.w));  

    // quadratic case
    vec3 roots2 = vec3(quadratic_roots(coeff.xyz), degenerate);

    // normalize coefficients
    coeff.xyz /= mix(1.0, coeff.w, is_cubic);
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
    float is_positive = step(0.0, discriminant);

    // compute depressed coefficients depressed[0] + depressed[1] * x + x^3 eq(0.16)
    vec2 depressed = vec2(delta.y - 2.0 * coeff.z * delta.x, delta.x);
    
    // compute cubic roots using complex number formula eq(0.14)  
    float theta = atan(sqrt_discrim, -depressed.x) / 3.0;
    vec2 cubic_root = vec2(cos(theta), sin(theta));

    // compute real root using cubic root formula for one real and two complex roots eq(0.15)
    vec3 roots21 = vec3(cbrt((-depressed.x + sqrt_discrim) * 0.5) + cbrt((-depressed.x - sqrt_discrim) * 0.5));
    
    // compute three roots via rotation, applying complex root formula eq(0.14)
    vec3 roots3 = vec3(
        cubic_root.x,                                                   // First root
        dot(vec2(-0.5, -0.5 * sqrt(3.0)), cubic_root),   // Second root (rotated by 120 degrees)
        dot(vec2(-0.5, 0.5 * sqrt(3.0)), cubic_root)     // Third root (rotated by -120 degrees)
    );

    // sort and scale the three real roots
    roots3 = sqrt(max(epsilon, -depressed.y)) * roots3 * 2.0; // gl_FragColor = vec4(vec3(any(isnan(roots3)), 0.0, any(isinf(roots3))), 1.0);
    roots3 = sort(roots3);     

    // combine cases and revert transformation eq(0.2) and eq(0.16)
    vec3 roots;
    roots = mix(roots21, roots3, is_positive) - coeff.z;
    roots = mix(roots2, roots,  is_cubic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);

    return roots;
}

// Solves a cubic equation given the coefficients:
// a * x^3 + b * x^2 + c * x + d 
// Shadertoy example (// https://www.shadertoy.com/view/7tBGzK)
int cubic_roots(in float a, in float b, in float c, in float d, out vec3 roots) 
{
    float u = b / (3.0 * a);

    // Depress to x^3 + px + q by substituting x-b/3a
    // This can be found by substituting x+u and solving for u so that the x^2
    // term gets eliminated (then of course dividing by the leading coefficient)
    float p = (c - b * u) / a;
    float q = (d - (c - 2.0 * b * b / (9.0 * a)) * u) / a;

    // Everything blows up when p=0 so give this case special treatment
    if (abs(p) < 1e-9) { roots.x = cbrt(-q) - u; return 1; }

    // In the case of one root, this construction does not work
    float h = 0.25 * q * q + p * p * p / 27.0;
    if (h > 0.0) // Check depressed cubic discriminant 
    { 
        h = sqrt(h);
        float o = -0.5 * q;
        roots.x = cbrt(o - h) + cbrt(o + h) - u; // Cardano's formula (see https://en.wikipedia.org/wiki/Cubic_equation)
        return 1;
    }

    // Solve by mapping an inverse smoothstep between the critical points
    // I found a whole lot simplified right out so now it probably looks rather obfuscated
    float m = sqrt(-p / 3.0);
    roots.x = -2.0 * m * sin(asin(1.5 * q / (p * m)) / 3.0);

    // Factor out the root to solve for the rest as a quadratic
    h = sqrt(-3.0 * roots.x * roots.x - 4.0 * p);
    roots.yz = 0.5 * vec2(h - roots.x, -h - roots.x);
    roots -= u; // Undo the change in variable

    return 3;
}

