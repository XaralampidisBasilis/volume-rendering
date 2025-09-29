#ifndef COLORMAP_PLASMA
#define COLORMAP_PLASMA 16

#ifndef PALETTE
#include "../palette"
#endif

vec3 plasma(float t) 
{
    vec3 a  = vec3(0.260353, 0.643741, 0.401505);
    vec3 b1 = vec3(0.925001, 0.641300, 0.244923);
    vec3 c1 = vec3(0.451398, 0.362059, 0.688036);
    vec3 d1 = vec3(0.674213, 0.466824, -0.150012);
    vec3 b2 = vec3(0.249030, 0.020714, 0.015128);
    vec3 c2 = vec3(0.709559, 1.885207, 2.000000);
    vec3 d2 = vec3(1.058190, 0.031753, 0.567507);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif