#ifndef CUBIC_ROOTS
#define CUBIC_ROOTS

// Special cube root to fix GLSL's negative pow() bug
float cbrt(in float x) { return sign(x) * pow(abs(x), 1.0 / 3.0); }

// Based on Blinn's paper (https://courses.cs.washington.edu/courses/cse590b/13au/lecture_notes/solvecubic_p5.pdf)
// Article by Christoph Peters (https://momentsingraphics.de/CubicRoots.html#_Blinn07b)
// Solves a cubic equation given the coefficients: 
// coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3
vec3 cubic_roots(in vec4 coeff, out float is_solvable)
{
    // check if cubic
    float is_cubic = step(EPSILON6, abs(coeff.w));  
    coeff.w = mix(1.0, coeff.w, is_cubic); // if not quadratic, set coeff w = 1 to avoid numerical erros in mix(roots2.xyy, roots, is_cubic)

    // quadratic case
    vec2 roots2 = quadratic_roots(coeff.xyz, is_solvable);
    is_solvable = mix(is_solvable, 1.0, is_cubic); // a cubic has always at least one real root

    // normalize coefficients
    coeff.xyz /= coeff.w;
    coeff.yz /= 3.0;

    // compute hessian coeeficents eq(0.4)
    vec3 delta = vec3(
        coeff.y - coeff.z * coeff.z,                          // δ1 = coeff.w * coeff.y - coeff.z^2
        coeff.x - coeff.y * coeff.z,                          // δ2 = coeff.w * coeff.x - coeff.y * coeff.z
        dot(vec2(coeff.z, -coeff.y), coeff.xy)    // δ3 = coeff.z * coeff.x - coeff.y * coeff.x
    );

    // compute depressed cubic and discriminant eq(0.16) eq(0.7)
    // coefficients depressed[0] + depressed[1] * x + x^3
    vec2 depressed = vec2(delta.y - 2.0 * coeff.z * delta.x, delta.x);
    float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy); // Δ = δ1 * δ3 - δ2^2
    float sqrt_discrim = sqrt(abs(discriminant));
    float is_positive = step(EPSILON6, discriminant);
    
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
    roots3 = sqrt(max(EPSILON6, -depressed.y)) * roots3 * 2.0; // gl_FragColor = vec4(vec3(any(isnan(roots3)), 0.0, any(isinf(roots3))), 1.0);
    roots3 = sort(roots3);     

    // combine cases and revert transformation eq(0.2) and eq(0.16)
    vec3 roots = mix(roots21, roots3, is_positive) - coeff.z;
    roots = mix(roots2.xyy, roots,  is_cubic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);

    return roots;
}

// use when sure there is a real solution
// coefficient[0] * x^0 + coefficient[1] * x^1 + coefficient[2] * x^2 + coefficient[3] * x^3
vec3 cubic_roots(in vec4 coeff)
{
    // check if cubic
    float is_cubic = step(EPSILON6, abs(coeff.w));  
    coeff.w = mix(1.0, coeff.w, is_cubic); // if not quadratic, set coeff w = 1 to avoid numerical erros in mix(roots2.xyy, roots, is_cubic)

    // quadratic case
    vec2 roots2 = quadratic_roots(coeff.xyz);

    // normalize coefficients
    coeff.xyz /= coeff.w;
    coeff.yz /= 3.0;

    // compute hessian coeeficents eq(0.4)
    vec3 delta = vec3(
        coeff.y - coeff.z * coeff.z,                          // δ1 = coeff.w * coeff.y - coeff.z^2
        coeff.x - coeff.y * coeff.z,                          // δ2 = coeff.w * coeff.x - coeff.y * coeff.z
        dot(vec2(coeff.z, -coeff.y), coeff.xy)    // δ3 = coeff.z * coeff.x - coeff.y * coeff.x
    );

    // compute depressed cubic and discriminant eq(0.16) eq(0.7)
    // coefficients depressed[0] + depressed[1] * x + x^3
    vec2 depressed = vec2(delta.y - 2.0 * coeff.z * delta.x, delta.x);
    float discriminant = dot(vec2(4.0 * delta.x, -delta.y), delta.zy); // Δ = δ1 * δ3 - δ2^2
    float sqrt_discrim = sqrt(abs(discriminant));
    float is_positive = step(EPSILON6, discriminant);
    
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
    roots3 = sqrt(max(EPSILON6, -depressed.y)) * roots3 * 2.0; // gl_FragColor = vec4(vec3(any(isnan(roots3)), 0.0, any(isinf(roots3))), 1.0);
    roots3 = sort(roots3);     

    // combine cases and revert transformation eq(0.2) and eq(0.16)
    vec3 roots = mix(roots21, roots3, is_positive) - coeff.z;
    roots = mix(roots2.xyy, roots,  is_cubic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);

    return roots;
}


// Solves a cubic equation given the coefficients:
// a * x^3 + b * x^2 + c * x + d 
// Shadertoy example (// https://www.shadertoy.com/view/7tBGzK)
// int cubic_roots(in float a, in float b, in float c, in float d, out vec3 roots) 
// {
//     float u = b / (3.0 * a);

//     // Depress to x^3 + px + q by substituting x-b/3a
//     // This can be found by substituting x+u and solving for u so that the x^2
//     // term gets eliminated (then of course dividing by the leading coefficient)
//     float p = (c - b * u) / a;
//     float q = (d - (c - 2.0 * b * b / (9.0 * a)) * u) / a;

//     // Everything blows up when p=0 so give this case special treatment
//     if (abs(p) < 1e-9) { roots.x = cbrt(-q) - u; return 1; }

//     // In the case of one root, this construction does not work
//     float h = 0.25 * q * q + p * p * p / 27.0;
//     if (h > 0.0) // Check depressed cubic discriminant 
//     { 
//         h = sqrt(h);
//         float o = -0.5 * q;
//         roots.x = cbrt(o - h) + cbrt(o + h) - u; // Cardano's formula (see https://en.wikipedia.org/wiki/Cubic_equation)
//         return 1;
//     }

//     // Solve by mapping an inverse smoothstep between the critical points
//     // I found a whole lot simplified right out so now it probably looks rather obfuscated
//     float m = sqrt(-p / 3.0);
//     roots.x = -2.0 * m * sin(asin(1.5 * q / (p * m)) / 3.0);

//     // Factor out the root to solve for the rest as a quadratic
//     h = sqrt(-3.0 * roots.x * roots.x - 4.0 * p);
//     roots.yz = 0.5 * vec2(h - roots.x, -h - roots.x);
//     roots -= u; // Undo the change in variable

//     return 3;
// }

#endif // CUBIC_ROOTS
