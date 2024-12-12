#ifndef NAND
#define NAND

#ifndef AND
#include "./and"
#endif

float nand(in bool  a, in bool  b) { return 1.0 - and(a, b); }
vec2  nand(in bvec2 a, in bvec2 b) { return 1.0 - and(a, b); }
vec3  nand(in bvec3 a, in bvec3 b) { return 1.0 - and(a, b); }
vec4  nand(in bvec4 a, in bvec4 b) { return 1.0 - and(a, b); }
float nand(in float a, in float b) { return 1.0 - and(a, b) ;}
vec2  nand(in vec2  a, in vec2  b) { return 1.0 - and(a, b) ;}
vec3  nand(in vec3  a, in vec3  b) { return 1.0 - and(a, b) ;}
vec4  nand(in vec4  a, in vec4  b) { return 1.0 - and(a, b) ;}

#endif