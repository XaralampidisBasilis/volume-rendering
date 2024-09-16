// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(in vec3 coeff, out float is_solvable) 
{
    const vec2 signs = vec2(-1.0, 1.0);

    // check if quadratic
    float is_quadratic = step(EPSILON6, abs(coeff.z));  
    coeff.z = mix(1.0, coeff.z, is_quadratic);  // if not quadratic, set coeff.z = 1 to avoid numerical erros in mix(roots1, roots2, is_quadratic)

    // linear case
    vec2 roots1 = vec2(linear_root(coeff.xy, is_solvable));

    // normalize coefficients
    coeff.xy /= coeff.z; // gl_FragColor = vec4(vec3(any(isinf(coeff))), 1.0);
    coeff.y /= 2.0;
    
    // calculate discriminant
    float discriminant = coeff.y * coeff.y - coeff.x;
    float is_positive = step(EPSILON6, discriminant);
    is_solvable = mix(is_solvable, is_positive, is_quadratic);

    // quadratic case
    vec2 roots2 = sqrt(max(EPSILON6, discriminant)) * signs - coeff.y; 
    roots2 = sort(roots2);

    // combine cases
    vec2 roots = mix(roots1, roots2, is_quadratic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);
    
    return roots;
}


// use when sure there is a real solution
// coeff[0] + coeff[1] * t + coeff[2] * t^2
vec2 quadratic_roots(in vec3 coeff) 
{
    const vec2 signs = vec2(-1.0, 1.0);

    // check if quadratic
    float is_quadratic = step(EPSILON6, abs(coeff.z));  
    coeff.z = mix(1.0, coeff.z, is_quadratic);  // if not quadratic, set coeff.z = 1 to avoid numerical erros in mix(roots1, roots2, is_quadratic)

    // linear case
    vec2 roots1 = vec2(linear_root(coeff.xy));

    // normalize coefficients
    coeff.xy /= coeff.z; 
    coeff.y /= 2.0;
    
    // calculate discriminant
    float discriminant = coeff.y * coeff.y - coeff.x;

    // quadratic case
    vec2 roots2 = sqrt(max(EPSILON6, discriminant)) * signs - coeff.y; 
    roots2 = sort(roots2);

    // combine cases
    vec2 roots = mix(roots1, roots2, is_quadratic);
    // gl_FragColor = vec4(vec3(any(isinf(roots)), 0.0, any(isnan(roots))), 1.0);
    
    return roots;
}

