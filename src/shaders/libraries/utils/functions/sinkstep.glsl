// softstep with inflex point (1,1)

#ifndef SINKSTEP
#define SINKSTEP

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef MAP
#include "../map"
#endif

float sinkstep(in float edge0, in float edge1, in float x, in float slope)
{
    float t = map(edge0, edge1, x);
    float t_inv = 1.0 - t;
    float g = 1.0 / max(1.0 - slope, MICRO_TOLERANCE);
    float g_inv = 2.0 - g;
    float s = (t * t) / (1.0 - g_inv * t_inv);

    return s;
}

#endif
