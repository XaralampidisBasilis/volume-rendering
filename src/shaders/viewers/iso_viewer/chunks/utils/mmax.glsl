/*
contributors: Patricio Gonzalez Vivo
description: extend GLSL Max function to add more arguments
use:
    - <float> mmax(<float> A, <float> B, <float> C[, <float> D])
    - <vec2|vec3|vec4> mmax(<vec2|vec3|vec4> A)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/

#ifndef MMAX
#define MMAX

float mmax(in float a) { return a; }
float mmax(in float a, in float b) { return max(a, b); }
float mmax(in float a, in float b, in float c) { return max(a, max(b, c)); }
float mmax(in float a, in float b, in float c, in float d) { return max(max(a, b), max(c, d)); }

int mmax(in int a) { return a; }
int mmax(in int a, in int b) { return max(a, b); }
int mmax(in int a, in int b, in int c) { return max(a, max(b, c)); }
int mmax(in int a, in int b, in int c, in int d) { return max(max(a, b), max(c, d)); }

float mmax(const vec2 v) { return max(v.x, v.y); }
float mmax(const vec3 v) { return mmax(v.x, v.y, v.z); }
float mmax(const vec4 v) { return mmax(v.x, v.y, v.z, v.w); }

int mmax(const ivec2 v) { return max(v.x, v.y); }
int mmax(const ivec3 v) { return mmax(v.x, v.y, v.z); }
int mmax(const ivec4 v) { return mmax(v.x, v.y, v.z, v.w); }

#endif // MMAX
