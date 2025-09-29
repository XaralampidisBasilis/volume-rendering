#ifndef COLORMAP_CIVIDIS
#define COLORMAP_CIVIDIS 19

#ifndef PALETTE
#include "../palette"
#endif

vec3 cividis(float t) 
{
    vec3 a  = vec3(0.471158, 0.894980, -1.390197);
    vec3 b1 = vec3(1.441757, 1.133394, 1.864691);
    vec3 c1 = vec3(0.670921, 0.196915, 0.145757);
    vec3 d1 = vec3(0.424741, 0.578773, -0.064678);
    vec3 b2 = vec3(1.085652, 0.238494, 0.032514);
    vec3 c2 = vec3(0.768613, 0.378699, 1.467550);
    vec3 d2 = vec3(0.876007, 0.999533, -0.060326);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif