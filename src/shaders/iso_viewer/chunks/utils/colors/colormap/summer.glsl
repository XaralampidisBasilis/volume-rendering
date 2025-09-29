#ifndef COLORMAP_SUMMER
#define COLORMAP_SUMMER 6

#ifndef PALETTE
#include "../palette"
#endif

vec3 summer(float t) 
{
    vec3 a = vec3(0.499979, 0.749503, 0.400000);
    vec3 b = vec3(1.998634, 1.447229, -0.000000);
    vec3 c = vec3(0.080141, 0.055144, 0.732340);
    vec3 d = vec3(0.709931, 0.722482, 0.133830);
    return palette(t, a, b, c, d);
}

#endif