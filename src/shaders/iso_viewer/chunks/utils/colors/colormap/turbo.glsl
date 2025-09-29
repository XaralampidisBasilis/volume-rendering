#ifndef COLORMAP_TURBO
#define COLORMAP_TURBO 1

#ifndef PALETTE
#include "../palette"
#endif

vec3 turbo(float t) 
{
    vec3 a  = vec3(-1.173583, 1.089549, 0.363003);
    vec3 b0 = vec3(1.999787, -1.091536, 0.596810);
    vec3 c0 = vec3(0.168544, 0.690975, 1.090372);
    vec3 d0 = vec3(0.843290, 0.188794, -0.342117);
    vec3 b1 = vec3(0.265151, 1.180907, -0.376009);
    vec3 c1 = vec3(1.460237, 0.381460, 1.554106);
    vec3 d1 = vec3(0.995900, 0.331064, 0.346513);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif