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
float mmax(vec2 v) { return max(v.x, v.y); }
float mmax(vec3 v) { return mmax(v.x, v.y, v.z); }
float mmax(vec4 v) { return mmax(v.x, v.y, v.z, v.w); }
float mmax(float v[5]) 
{
    float r = v[0];
    r = max(r, v[1]);
    r = max(r, v[2]);
    r = max(r, v[3]);
    r = max(r, v[4]);
    return r;
}
float mmax(float v[6]) 
{
    float r = v[0];
    r = max(r, v[1]);
    r = max(r, v[2]);
    r = max(r, v[3]);
    r = max(r, v[4]);
    r = max(r, v[5]);
    return r;
}
vec2 mmax(mat2 A)
{
    vec2 r;
    r[0] = mmax(A[0]);
    r[1] = mmax(A[1]);
    return r;
}
vec3 mmax(mat3 A)
{
    vec3 r;
    r[0] = mmax(A[0]);
    r[1] = mmax(A[1]);
    r[2] = mmax(A[2]);
    return r;
}
vec4 mmax(mat4 A)
{
    vec4 r;
    r[0] = mmax(A[0]);
    r[1] = mmax(A[1]);
    r[2] = mmax(A[2]);
    r[3] = mmax(A[3]);
    return r;
}

#endif // MMAX
