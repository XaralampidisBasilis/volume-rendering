/*
contributors: Patricio Gonzalez Vivo
description: extend GLSL min function to add more arguments
use:
    - min(<float> A, <float> B, <float> C[, <float> D])
    - min(<vec2|vec3|vec4> A)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/

#ifndef MMIN
#define MMIN

float mmin(in float a) { return a; }
float mmin(in float a,in float b) { return min(a, b); }
float mmin(in float a,in float b, in float c) { return min(a, min(b, c)); }
float mmin(in float a,in float b, in float c, in float d) { return min(min(a,b), min(c, d)); }

int mmin(in int a) { return a; }
int mmin(in int a,in int b) { return min(a, b); }
int mmin(in int a,in int b, in int c) { return min(a, min(b, c)); }
int mmin(in int a,in int b, in int c, in int d) { return min(min(a,b), min(c, d)); }

float mmin(vec2 v) { return min(v.x, v.y); }
float mmin(vec3 v) { return mmin(v.x, v.y, v.z); }
float mmin(vec4 v) { return mmin(v.x, v.y, v.z, v.w); }

int mmin(ivec2 v) { return min(v.x, v.y); }
int mmin(ivec3 v) { return mmin(v.x, v.y, v.z); }
int mmin(ivec4 v) { return mmin(v.x, v.y, v.z, v.w); }

#endif // MMIN
