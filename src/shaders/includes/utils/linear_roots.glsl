
// coeff[0] + coeff[1] * t
float linear_roots(in vec2 coeff) 
{
    const float degenerate = -1.0;
    const float epsilon = 1e-6;

    // check if linear
    float is_linear = step(epsilon, abs(coeff.y));

    // degenerate case
    float root0 = degenerate;

    // linear case
    float root1 = mix(degenerate, -coeff.x / coeff.y, is_linear);

    // combine cases
    float root = mix(root0,  root1, is_linear);
    // gl_FragColor = vec4(vec3(isinf(root), 0.0, isnan(root)), 1.0);

    return root;
}