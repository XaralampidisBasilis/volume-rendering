  // source : https://www.peterstock.co.uk/games/adjustable_smoothstep/
  // formulas in desmos : https://www.desmos.com/calculator/ovekxhisxy
  // glsl code in desmos : https://www.desmos.com/calculator/ntzzn2a38x

/**
 * Generates a aoft transition from edge0 to edge1 with adjustable inflection point and slope, similar to smoothstep.
 *
 * @param edge0   : The lower edge of the transition (float)
 * @param edge1   : The upper edge of the transition (float)
 * @param x       : The input value to be mapped within the edges (float)
 * @param slope   : The normalized slope to control the smoothness of the transition in the range [0, 1], where 0 and 1 corespond to linear and abrupt transition respectively (float)
 * @param p_inflex: The inflection point x of the curve where the second derivative, curvature, changes sign (float)
 * @param q_inflex: The inflection point y of the curve where the second derivative, curvature, changes sign (float)
 * @return        : A smooth transition value in the range [0, 1] (float)
 */
#ifndef SOFTSTEP
#define SOFTSTEP

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

float softstep(in float edge0, in float edge1, in float x)
{
    float t = map(edge0, edge1, x);
    float g = 1.5;                      // best approximation to smoothstep
    vec2 pq = vec2(0.5); // best approximation to smoothstep
    float q_max = pq.x * g;
    float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, pq.x, clamp(q_min, q_max, pq.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(MICRO_TOLERANCE), vec3(1.0 - MICRO_TOLERANCE), params);

    float g_scaled = (params.y / params.z) * g - 2.0;
    float t_scaled = params.x / params.y;
    float s = params.z * pow2(t_scaled);
    s /= (1.0 - t_scaled) * g_scaled + 1.0;

    return mix(s, 1.0 - s, is_above);
}

float softstep(in float edge0, in float edge1, in float x, in float slope)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    vec2 pq = vec2(0.5); // best approximation to smoothstep
    float q_max = pq.x * g;
    float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, pq.x, clamp(q_min, q_max, pq.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(MICRO_TOLERANCE), vec3(1.0 - MICRO_TOLERANCE), params);

    float g_scaled = (params.y / params.z) * g - 2.0;
    float t_scaled = params.x / params.y;
    float s = params.z * pow2(t_scaled);
    s /= (1.0 - t_scaled) * g_scaled + 1.0;

    return mix(s, 1.0 - s, is_above);
}

float softstep(in float edge0, in float edge1, in float x, in float slope, in float p_inflex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    vec2 pq = vec2(p_inflex);
    float q_max = pq.x * g;
    float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, pq.x, clamp(q_min, q_max, pq.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(MICRO_TOLERANCE), vec3(1.0 - MICRO_TOLERANCE), params);

    float g_scaled = (params.y / params.z) * g - 2.0;
    float t_scaled = params.x / params.y;
    float s = params.z * pow2(t_scaled);
    s /= (1.0 - t_scaled) * g_scaled + 1.0;

    return mix(s, 1.0 - s, is_above);
}

float softstep(in float edge0, in float edge1, in float x, in float slope, in float p_inflex, in float q_inflex)
{
    float t = map(edge0, edge1, x);
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    vec2 pq = vec2(p_inflex, q_inflex);
    float q_max = p_inflex * g;
    float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, pq.x, clamp(q_min, q_max, pq.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params = clamp(vec3(MICRO_TOLERANCE), vec3(1.0 - MICRO_TOLERANCE), params);

    float g_scaled = (params.y / params.z) * g - 2.0;
    float t_scaled = params.x / params.y;
    float s = params.z * pow2(t_scaled);
    s /= (1.0 - t_scaled) * g_scaled + 1.0;

    return mix(s, 1.0 - s, is_above);
}

#endif // SOFTSTEP
