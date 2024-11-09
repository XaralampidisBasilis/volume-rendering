#ifndef SOFTSTEP_CASES
#define SOFTSTEP_CASES

// softstep with inflex point (1,1)
float sinkstep(const in float edge0, const in float edge1, const in float x, const in float slope)
{
    float t = map(edge0, edge1, x);
    float t_inv = 1.0 - t;
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    float g_inv = 2.0 - g;
    float s = pow2(t) / (1.0 - g_inv * t_inv);

    return s;
}

// softstep with inflex point (0,0)
float hillstep(const in float edge0, const in float edge1, const in float x, const in float slope)
{
    float t = map(edge0, edge1, x);
    float t_inv = 1.0 - t;
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    float g_inv = 2.0 - g;
    float s = 1.0 - pow2(t_inv) / (1.0 - g_inv * t);

    return s;
}

#endif // SOFTSTEP_CASES
