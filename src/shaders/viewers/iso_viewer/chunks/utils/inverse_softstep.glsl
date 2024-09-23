// https://www.peterstock.co.uk/games/adjustable_smoothstep/
// https://www.desmos.com/calculator/ovekxhisxy

float inverse_softstep(const in float x, const in float p, const in float q, const in float s)
{
    const float g = 1.0 / max(1.0 - s, EPSILON6);
    const float p_max = q* g;
    const float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(x, clamp(p_max, p_min, p), q);
    float is_above = step(params.y, x);

    params = mix(params, vec3(1.0) - params, is_above);
    params.y = clamp(EPSILON6, 1.0 - EPSILON6, params.y);

    float g_scaled = (params.z / params.y) * g - 1.0;

    float c = 1.0 / maxabs(1.0 - g_scaled, EPSILON9);

    params.x *= (params.z / params.y) / c / 2.0;

    float c_scaled = params.z * (c - 1.0) * 2.0;

    float y = params.x + sqrt(params.x * (params.x + c_scaled));
    y = mix(y, 1.0 - y, is_above);

    return y;
}