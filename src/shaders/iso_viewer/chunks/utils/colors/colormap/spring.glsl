#ifndef COLORMAP_SPRING
#define COLORMAP_SPRING 5

#ifndef PALETTE
#include "../palette"
#endif

vec3 spring(float t) 
{
    vec3 a = vec3(1.000000, 0.500001, 0.500001);
    vec3 b = vec3(0.000000, 1.999808, 1.999812);
    vec3 c = vec3(0.745176, 0.080093, 0.080093);
    vec3 d = vec3(0.127412, 0.709953, 0.209954);
    return palette(t, a, b, c, d);
}

#endif