#ifndef XNOR
#define XNOR

#ifndef XOR
#include "./xor"
#endif

float xnor(in bool  a, in bool  b) { return 1.0 - xor(a, b); }
vec2  xnor(in bvec2 a, in bvec2 b) { return 1.0 - xor(a, b); }
vec3  xnor(in bvec3 a, in bvec3 b) { return 1.0 - xor(a, b); }
vec4  xnor(in bvec4 a, in bvec4 b) { return 1.0 - xor(a, b); }
float xnor(in float a, in float b) { return 1.0 - xor(a, b) ;}
vec2  xnor(in vec2  a, in vec2  b) { return 1.0 - xor(a, b) ;}
vec3  xnor(in vec3  a, in vec3  b) { return 1.0 - xor(a, b) ;}
vec4  xnor(in vec4  a, in vec4  b) { return 1.0 - xor(a, b) ;}

#endif