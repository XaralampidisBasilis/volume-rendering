#ifndef COLORMAP_AUTUMN
#define COLORMAP_AUTUMN 7

#ifndef PALETTE
#include "../palette"
#endif

vec3 autumn(float t) 
{
    vec3 a = vec3(1.000000, 0.500000, 0.000000);
    vec3 b = vec3(-0.000000, 1.999988, 0.000000);
    vec3 c = vec3(0.745176, 0.080086, 0.714514);
    vec3 d = vec3(0.127412, 0.709957, 0.142743);
    return palette(t, a, b, c, d);
}

#endif