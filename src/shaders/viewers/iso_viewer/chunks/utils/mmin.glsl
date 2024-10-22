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

float mmin(const in float a) { return a; }
float mmin(const in float a,const in float b) { return min(a, b); }
float mmin(const in float a,const in float b, const in float c) { return min(a, min(b, c)); }
float mmin(const in float a,const in float b, const in float c, const in float d) { return min(min(a,b), min(c, d)); }

int mmin(const in int a) { return a; }
int mmin(const in int a,const in int b) { return min(a, b); }
int mmin(const in int a,const in int b, const in int c) { return min(a, min(b, c)); }
int mmin(const in int a,const in int b, const in int c, const in int d) { return min(min(a,b), min(c, d)); }

float mmin(const vec2 v) { return min(v.x, v.y); }
float mmin(const vec3 v) { return mmin(v.x, v.y, v.z); }
float mmin(const vec4 v) { return mmin(v.x, v.y, v.z, v.w); }

int mmin(const ivec2 v) { return min(v.x, v.y); }
int mmin(const ivec3 v) { return mmin(v.x, v.y, v.z); }
int mmin(const ivec4 v) { return mmin(v.x, v.y, v.z, v.w); }

#endif // MMIN
