  // source : https://www.peterstock.co.uk/games/adjustable_smoothstep/
  // formulas in desmos : https://www.desmos.com/calculator/ovekxhisxy
  // glsl code in desmos : https://www.desmos.com/calculator/ntzzn2a38x

/**
 * Generates a aoft transition from edge0 to edge1 with adjustable inflection point and slope, similar to smoothstep.
 *
 * @param edge0     : The lower edge of the transition (float)
 * @param edge1     : The upper edge of the transition (float)
 * @param x         : The input value to be mapped within the edges (float)
 * @param slope     : The normalized slope to control the smoothness of the transition in the range [0, 1], where 0 and 1 corespond to linear and abrupt transition respectively (float)
 * @param inflection: The inflection point of the curve where the second derivative, curvature, changes sign (vec2)
 * @return : A smooth transition value in the range [0, 1] (float)
 */

float softstep(const in float edge0, const in float edge1, const in float x)
{
    const float inflection = vec2(0.5); // best approximation to smoothstep
    const float slope = 1.0 / 3.0;            // best approximation to smoothstep
    const float t = map(edge0, edge1, x);
    const float g = 1.0 / max(1.0 - slope, EPSILON6);
    const float q_max = inflection.y * g;
    const float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, inflection.x, clamp(q_min, q_max, inflection.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params.z = clamp(EPSILON6, 1.0 - EPSILON6, params.z);

    float g_scaled = (params.y / params.z) * g - 1.0;
    float c = 1.0 / maxabs(1.0 - g_scaled, EPSILON9);
    params.x *= (params.z / params.y) * c;

    float c_scaled = params.z  * c * (c - 1.0);
    float y = params.x * params.x  / (params.x + c_scaled);

    return mix(y, 1.0 - y, is_above);
}


float softstep(const in float edge0, const in float edge1, const in float x, const in float slope)
{
    const float inflection = vec2(0.5); // best approximation to smoothstep
    const float t = map(edge0, edge1, x);
    const float g = 1.0 / max(1.0 - slope, EPSILON6);
    const float q_max = inflection.y * g;
    const float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, inflection.x, clamp(q_min, q_max, inflection.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params.z = clamp(EPSILON6, 1.0 - EPSILON6, params.z);

    float g_scaled = (params.y / params.z) * g - 1.0;
    float c = 1.0 / maxabs(1.0 - g_scaled, EPSILON9);
    params.x *= (params.z / params.y) * c;

    float c_scaled = params.z  * c * (c - 1.0);
    float y = params.x * params.x  / (params.x + c_scaled);

    return mix(y, 1.0 - y, is_above);
}

float softstep(const in float edge0, const in float edge1, const in float x, const in float slope, const in vec2 inflection,)
{
    const float t = map(edge0, edge1, x);
    const float g = 1.0 / max(1.0 - slope, EPSILON6);
    const float q_max = inflection.y * g;
    const float q_min = q_max - g + 1.0 ;

    vec3 params = vec3(t, inflection.x, clamp(q_min, q_max, inflection.y));
    float is_above = step(params.y, t);
    params = mix(params, vec3(1.0) - params, is_above);
    params.z = clamp(EPSILON6, 1.0 - EPSILON6, params.z);

    float g_scaled = (params.y / params.z) * g - 1.0;
    float c = 1.0 / maxabs(1.0 - g_scaled, EPSILON9);
    params.x *= (params.z / params.y) * c;

    float c_scaled = params.z  * c * (c - 1.0);
    float y = params.x * params.x  / (params.x + c_scaled);

    return mix(y, 1.0 - y, is_above);
}