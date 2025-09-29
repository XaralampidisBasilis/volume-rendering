#ifndef COLORMAP_COPPER
#define COLORMAP_COPPER 11

#ifndef PALETTE
#include "../palette"
#endif

vec3 copper(float t) 
{
    vec3 a = vec3(0.475474, 0.390606, 0.248753);
    vec3 b = vec3(0.545609, 1.863885, 1.362622);
    vec3 c = vec3(0.404723, 0.067001, 0.058301);
    vec3 d = vec3(0.596710, 0.716499, 0.720849);
    return palette(t, a, b, c, d);
}

#endif