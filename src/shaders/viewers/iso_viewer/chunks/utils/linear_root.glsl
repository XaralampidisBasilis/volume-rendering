
// coeff[0] + coeff[1] * t
float linear_root(in vec2 coeff, out float is_solvable) 
{
    // check if linear
    float is_linear = step(EPSILON6, abs(coeff.y));
    coeff.y = maxabs(EPSILON6, coeff.y);

    // check if identity
    float is_identity = step(abs(coeff.x), EPSILON6) * (1.0 - is_linear); // if both coefficients are zero then equation is identity
    is_solvable = mix(is_identity, 1.0, is_linear); 
        
    float root = -coeff.x / coeff.y;
    // gl_FragColor = vec4(vec3(isinf(root), 0.0, isnan(root)), 1.0);

    return root;
}

// use when sure there is a real solution
// coeff[0] + coeff[1] * t
float linear_root(in vec2 coeff) 
{    
    // avoid division by zero
    coeff.y = maxabs(EPSILON6, coeff.y);

    float root = -coeff.x / coeff.y;
    // gl_FragColor = vec4(vec3(isinf(root), 0.0, isnan(root)), 1.0);

    return root;
}