#ifndef INVERSE_SOFTSTEP
#define INVERSE_SOFTSTEP

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

#ifndef NANO_TOLERANCE
#define NANO_TOLERANCE 1e-9
#endif

#ifndef POWN
#include "./pown"
#endif

// source : https://www.peterstock.co.uk/games/adjustable_smoothstep/
// formulas in desmos : https://www.desmos.com/calculator/ovekxhisxy
// glsl code in desmos : https://www.desmos.com/calculator/4anckbpwml

float inverse_softstep(in float edge0, in float edge1, in float x)
{
    float t = map(edge0, edge1, x);
    float g = 3.0;              // best approximation to inverse smoothstep
    vec2 pq = vec2(0.5); // best approximation to inverse smoothstep
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(MICRO_TOLERANCE), vec3(1.0 - MICRO_TOLERANCE), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(in float edge0, in float edge1, in float x, in float slope)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, NANO_TOLERANCE);
    vec2 pq = vec2(0.5); // best approximation to inverse smoothstep
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(NANO_TOLERANCE), vec3(1.0 - NANO_TOLERANCE), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(in float edge0, in float edge1, in float x, in float slope, in float p_infex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, NANO_TOLERANCE);
    vec2 pq = vec2(p_infex);
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(NANO_TOLERANCE), vec3(1.0 - NANO_TOLERANCE), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

float inverse_softstep(in float edge0, in float edge1, in float x, in float slope, in float p_infex, in float q_infex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(slope, NANO_TOLERANCE);
    vec2 pq = vec2(p_infex, q_infex);
    float p_max = pq.y * g;
    float p_min = p_max - g + 1.0 ;

    vec3 params = vec3(t, clamp(p_min, p_max, pq.x), pq.y);
    float is_above = step(params.y, x);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(NANO_TOLERANCE), vec3(1.0 - NANO_TOLERANCE), params);

    float g_scaled = (params.z / params.y) * g * 0.5 - 1.0;
    float t_scaled = params.x / params.y;
    float y = pow2(t_scaled * g_scaled + 1.0) + t_scaled - 1.0;
    y = (sqrt(y) - t_scaled * g_scaled) * params.z;

    return mix(y, 1.0 - y, is_above);
}

#endif // INVERSE_SOFTSTEP