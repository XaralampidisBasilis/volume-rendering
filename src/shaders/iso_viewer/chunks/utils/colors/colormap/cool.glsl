#ifndef COLORMAP_COOL
#define COLORMAP_COOL 4

#ifndef PALETTE
#include "../palette"
#endif

vec3 cool(float t) 
{
    vec3 a = vec3(0.500001, 0.500000, 1.000000);
    vec3 b = vec3(1.999655, 1.999654, 0.000000);
    vec3 c = vec3(0.080099, 0.080099, 0.745176);
    vec3 d = vec3(0.709950, 0.209950, 0.127412);
    return palette(t, a, b, c, d);
}

#endif