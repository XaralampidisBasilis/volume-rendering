#ifndef COLORMAP_WINTER
#define COLORMAP_WINTER 8

#ifndef PALETTE
#include "../palette"
#endif

vec3 winter(float t) 
{
    vec3 a = vec3(-0.000000, 0.500001, 0.750010);
    vec3 b = vec3(-0.000000, 1.999953, 1.430454);
    vec3 c = vec3(0.714514, 0.080087, 0.055794);
    vec3 d = vec3(0.142743, 0.709956, 0.222104);
    return palette(t, a, b, c, d);
}

#endif