
#include "../sdf/triSDF.glsl"

#include "fill.glsl"
#include "stroke.glsl"

/*
contributors: Patricio Gonzalez Vivo
description: Draw a triangle filled or not.
use: tri(<vec2> st, <float> size [, <float> width])
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/

#ifndef FNC_TRI
#define FNC_TRI
float tri(vec2 st, float size) {
    return fill(triSDF(st), size);
}

float tri(vec2 st, float size, float strokeWidth) {
    return stroke(triSDF(st), size, strokeWidth);
}
#endif