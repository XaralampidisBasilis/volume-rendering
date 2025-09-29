#ifndef COLORMAP_PINK
#define COLORMAP_PINK 12

#ifndef PALETTE
#include "../palette"
#endif

vec3 pink(float t) 
{
    vec3 a  = vec3(-0.483794, -0.777930, -0.293682);
    vec3 b0 = vec3(1.988198, 1.900866, 1.999968);
    vec3 c0 = vec3(0.313872, 0.125783, 0.246824);
    vec3 d0 = vec3(-0.242539, 0.825271, 0.729959);
    vec3 b1 = vec3(0.593545, 0.029151, 0.736390);
    vec3 c1 = vec3(0.583510, 1.776750, 0.478608);
    vec3 d1 = vec3(1.077824, 0.775436, 1.088446);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif