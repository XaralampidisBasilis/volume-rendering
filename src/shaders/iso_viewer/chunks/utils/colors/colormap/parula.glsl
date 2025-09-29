#ifndef COLORMAP_PARULA
#define COLORMAP_PARULA 0

#ifndef PALETTE
#include "../palette"
#endif

vec3 parula(float t) 
{
    vec3 a  = vec3(0.541454, 1.968902, 0.559818);
    vec3 b1 = vec3(0.460347, 1.998354, 0.429174);
    vec3 c1 = vec3(0.645892, 0.330375, 0.763244);
    vec3 d1 = vec3(0.309938, 0.387593, -0.187696);
    vec3 b2 = vec3(-0.154889, 0.704319, 0.011011);
    vec3 c2 = vec3(1.667578, 0.717541, 2.000000);
    vec3 d2 = vec3(0.135293, 0.686891, 0.102776);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif