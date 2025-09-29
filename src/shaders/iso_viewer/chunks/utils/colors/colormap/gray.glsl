#ifndef COLORMAP_GRAY
#define COLORMAP_GRAY 9

#ifndef PALETTE
#include "../palette"
#endif

vec3 gray(float t) 
{
    vec3 a = vec3(0.500000, 0.500000, 0.500000);
    vec3 b = vec3(1.999993, 1.999993, 1.999993);
    vec3 c = vec3(0.080086, 0.080086, 0.080086);
    vec3 d = vec3(0.709957, 0.709957, 0.709957);
    return palette(t, a, b, c, d);
}

#endif