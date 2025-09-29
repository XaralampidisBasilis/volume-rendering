#ifndef COLORMAP_HSV
#define COLORMAP_HSV 2

#ifndef PALETTE
#include "../palette"
#endif

vec3 hsv(float t) 
{
    vec3 a  = vec3(0.345930, -1.151078, -1.327910);
    vec3 b0 = vec3(0.703838, 1.816049, 1.999886);
    vec3 c0 = vec3(1.417315, 0.237319, 0.228754);
    vec3 d0 = vec3(-0.210907, -0.120510, 0.880709);
    vec3 b1 = vec3(0.312792, 0.543745, 0.517213);
    vec3 c1 = vec3(2.000000, 0.995237, 1.018500);
    vec3 d1 = vec3(-0.003169, 0.719422, 0.269492);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif