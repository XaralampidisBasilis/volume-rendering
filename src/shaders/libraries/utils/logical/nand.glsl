#ifndef NAND
#define NAND

#ifndef AND
#include "./and"
#endif
#ifndef OFF
#include "./off"
#endif

bool  nand(in bool  a, in bool  b) { return off(and(a, b)); }
bvec2 nand(in bvec2 a, in bvec2 b) { return off(and(a, b)); }
bvec3 nand(in bvec3 a, in bvec3 b) { return off(and(a, b)); }
bvec4 nand(in bvec4 a, in bvec4 b) { return off(and(a, b)); }

bool  nand(in int   a, in int   b) { return off(and(a, b)); }
bvec2 nand(in ivec2 a, in ivec2 b) { return off(and(a, b)); }
bvec3 nand(in ivec3 a, in ivec3 b) { return off(and(a, b)); }
bvec4 nand(in ivec4 a, in ivec4 b) { return off(and(a, b)); }

bool  nand(in float a, in float b) { return off(and(a, b)); }
bvec2 nand(in vec2  a, in vec2  b) { return off(and(a, b)); }
bvec3 nand(in vec3  a, in vec3  b) { return off(and(a, b)); }
bvec4 nand(in vec4  a, in vec4  b) { return off(and(a, b)); }

#endif