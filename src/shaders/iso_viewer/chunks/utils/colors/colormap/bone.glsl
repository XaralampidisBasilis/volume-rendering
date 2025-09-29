#ifndef COLORMAP_BONE
#define COLORMAP_BONE 10

#ifndef PALETTE
#include "../palette"
#endif

vec3 bone(float t) 
{
    vec3 a = vec3(1.728560, 0.535898, -0.726993);
    vec3 b = vec3(2.000000, 0.583406, 2.000000);
    vec3 c = vec3(0.100690, 0.318709, 0.102955);
    vec3 d = vec3(0.587366, 0.576509, 0.809972);
    return palette(t, a, b, c, d);
}

#endif