#ifndef COLORMAP_VIRIDIS
#define COLORMAP_VIRIDIS 15

#ifndef PALETTE
#include "../palette"
#endif

vec3 viridis(float t) 
{
    vec3 a  = vec3(0.425268, -0.364758, 0.418135);
    vec3 b1 = vec3(1.125800, 1.306212, -1.205918);
    vec3 c1 = vec3(0.778337, 0.165380, 1.148509);
    vec3 d1 = vec3(0.296775, 0.795553, 0.047920);
    vec3 b2 = vec3(0.937521, 0.012337, -1.069593);
    vec3 c2 = vec3(0.891060, 1.453194, 1.217589);
    vec3 d2 = vec3(0.781272, 0.775696, 0.520518);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif