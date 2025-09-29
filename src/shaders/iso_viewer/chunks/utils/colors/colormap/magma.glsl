#ifndef COLORMAP_MAGMA
#define COLORMAP_MAGMA 18

#ifndef PALETTE
#include "../palette"
#endif

vec3 magma(float t) 
{
    vec3 a  = vec3(-0.386429, 0.394408, 0.409720);
    vec3 b1 = vec3(1.414174, 1.143924, 1.416815);
    vec3 c1 = vec3(0.189647, 0.676940, 0.641115);
    vec3 d1 = vec3(0.793470, 0.388450, -0.568490);
    vec3 b2 = vec3(0.079624, 0.813267, 1.330803);
    vec3 c2 = vec3(1.052351, 0.800573, 0.764647);
    vec3 d2 = vec3(0.286256, 0.854038, 0.863334);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif