#ifndef COLORMAP_HOT
#define COLORMAP_HOT 3

#ifndef PALETTE
#include "../palette"
#endif

vec3 hot(float t) 
{
    vec3 a  = vec3(0.434751, 0.499201, 0.553319);
    vec3 b0 = vec3(0.117871, 0.590260, 1.998983);
    vec3 c0 = vec3(1.395636, 0.560375, 0.692793);
    vec3 d0 = vec3(0.516179, 0.436002, 0.254912);
    vec3 b1 = vec3(0.669133, -0.097445,1.467678);
    vec3 c1 = vec3(0.457411, 1.673730, 0.848067);
    vec3 d1 = vec3(0.679382, 0.311157, 0.700754);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif