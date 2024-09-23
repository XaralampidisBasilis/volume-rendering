  // source : https://www.peterstock.co.uk/games/adjustable_smoothstep/
  // formulas in desmos : https://www.desmos.com/calculator/ovekxhisxy
  // glsl code in desmos : https://www.desmos.com/calculator/4anckbpwml

float inverse_softstep(const in float edge0, const in float edge1, const in float x)
{
    float t = map(edge0, edge1, x);
    float g = 3.0;              // best approximation to inverse smoothstep
    vec2 pq = vec2(0.5); // best approximation to inverse smoothstep
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(EPSILON6), vec3(1.0 - EPSILON6), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(const in float edge0, const in float edge1, const in float x, const in float slope)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, EPSILON6);
    vec2 pq = vec2(0.5); // best approximation to inverse smoothstep
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(EPSILON6), vec3(1.0 - EPSILON6), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(const in float edge0, const in float edge1, const in float x, const in float slope, const in float p_infex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, EPSILON6);
    vec2 pq = vec2(p_infex);
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(EPSILON6), vec3(1.0 - EPSILON6), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(const in float edge0, const in float edge1, const in float x, const in float slope, const in float p_infex, const in float q_infex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, EPSILON6);
    vec2 pq = vec2(p_infex, q_infex);
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(EPSILON6), vec3(1.0 - EPSILON6), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}