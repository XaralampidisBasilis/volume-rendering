#ifndef COLORMAP_INFERNO
#define COLORMAP_INFERNO 17

#ifndef PALETTE
#include "../palette"
#endif

vec3 inferno(float t) 
{
    vec3 a  = vec3(-0.575419, 0.417340, 0.285807);
    vec3 b1 = vec3(1.543616, 1.325364, 2.000000);
    vec3 c1 = vec3(0.174341, 0.656644, 1.696938);
    vec3 d1 = vec3(0.815911, 0.396624, -0.608185);
    vec3 b2 = vec3(0.095489, 0.951299, 1.871821);
    vec3 c2 = vec3(0.907917, 0.757037, 1.749972);
    vec3 d2 = vec3(0.380506, 0.870792, -0.130654);
    return palette(t, a, b1, c1, d1, b2, c2, d2);
}

#endif