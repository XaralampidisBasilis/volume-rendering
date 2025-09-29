#ifndef COLORMAP_PASTELJET
#define COLORMAP_PASTELJET 14

#ifndef PALETTE
#include "../palette"
#endif

vec3 pasteljet(float t) 
{
    vec3 a  = vec3(0.677942, 0.350764, 0.469527);
    vec3 b0 = vec3(-0.043513, -0.050359, 0.266445);
    vec3 c0 = vec3(2.000000, 2.000000, 0.698727);
    vec3 d0 = vec3(0.497311, 0.518843, -0.207068);
    vec3 b1 = vec3(0.338745, -0.561075, 0.062141);
    vec3 c1 = vec3(0.863745, 0.650179, 2.000000);
    vec3 d1 = vec3(0.437310, 0.223441, 0.010220);
    return palette(t, a, b0, c0, d0, b1, c1, d1);
}

#endif