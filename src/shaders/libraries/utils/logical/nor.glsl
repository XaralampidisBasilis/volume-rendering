#ifndef NOR
#define NOR

#ifndef OR
#include "./or"
#endif

float nor(in bool  a, in bool  b) { return 1.0 - or(a, b); }
vec2  nor(in bvec2 a, in bvec2 b) { return 1.0 - or(a, b); }
vec3  nor(in bvec3 a, in bvec3 b) { return 1.0 - or(a, b); }
vec4  nor(in bvec4 a, in bvec4 b) { return 1.0 - or(a, b); }
float nor(in float a, in float b) { return 1.0 - or(a, b) ;}
vec2  nor(in vec2  a, in vec2  b) { return 1.0 - or(a, b) ;}
vec3  nor(in vec3  a, in vec3  b) { return 1.0 - or(a, b) ;}
vec4  nor(in vec4  a, in vec4  b) { return 1.0 - or(a, b) ;}

#endif