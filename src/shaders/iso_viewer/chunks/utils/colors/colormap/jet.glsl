#ifndef COLORMAP_JET
#define COLORMAP_JET 13

#ifndef PALETTE
#include "../palette"
#endif

vec3 jet(float t) 
{
    vec3 a  = vec3(0.276022, 0.527041, 0.353694);
    vec3 b0 = vec3(0.597922, -0.201586, 0.559465);
    vec3 c0 = vec3(0.512799, 1.045576, 0.596704);
    vec3 d0 = vec3(0.573475, -0.103501, -0.104961);
    vec3 b1 = vec3(0.238268, 0.399577, -0.201583);
    vec3 c1 = vec3(1.424259, 1.047211, 1.500953);
    vec3 d1 = vec3(-0.012310, 0.518820, 0.058936);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif