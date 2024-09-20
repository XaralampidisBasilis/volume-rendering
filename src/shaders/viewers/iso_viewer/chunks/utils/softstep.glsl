
float softstep(const in float x, const in float p, const in float q, const in float s)
{
    const float g = 1.0 / max(1.0 - s, EPSILON6);
    const float q_max = p * g;
    const float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(x, p, clamp(q_min, q_max, q));
    float is_above = step(params.y, x);

    params = mix(params, vec3(1.0) - params, is_above);
    params.z = clamp(EPSILON6, 1.0 - EPSILON6, params.z);

    float g_scaled = (params.y / params.z) * g - 1.0;

    float c = 1.0 / maxabs(1.0 - g_scaled, EPSILON9);

    params.x *= (params.z / params.y) * c;

    float c_scaled = params.z  * c * (c - 1.0);

    float y = params.x * params.x  / (params.x + c_scaled);
    y = mix(y, 1.0 - y, is_above);

    return y;
}