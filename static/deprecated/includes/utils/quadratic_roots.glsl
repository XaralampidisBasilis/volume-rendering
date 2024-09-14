// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(in vec3 coeff) 
{
    const float degenerate = -1.0;
    const float epsilon = 1e-6;
    const vec2 signs = vec2(-1.0, 1.0);

    // check if quadratic
    float is_quadratic = step(epsilon, abs(coeff.z));  
    
    // degenerate and linear case
    vec2 roots0 = vec2(degenerate);
    vec2 roots1 = vec2(linear_root(coeff.xy));

    // normalize coefficients
    coeff.xy /= mix(1.0, coeff.z, is_quadratic); // gl_FragColor = vec4(vec3(any(isinf(coeff))), 1.0);
    coeff.y /= 2.0;
    
    // calculate discriminant
    float discriminant = coeff.y * coeff.y - coeff.x;
    float is_positive = step(0.0, discriminant);

    // quadratic case
    vec2 roots2 = sqrt(max(epsilon, discriminant)) * signs - coeff.y; 
    roots2 = sort(roots2);

    // combine cases
    vec2 roots;
    roots = mix(roots1, roots2, is_positive);
    roots = mix(roots0, roots,  is_quadratic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);
    
    return roots;
}
