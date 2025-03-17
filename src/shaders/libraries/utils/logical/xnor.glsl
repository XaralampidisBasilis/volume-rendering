#ifndef XNOR
#define XNOR

#ifndef XOR
#include "./xor"
#endif
#ifndef OFF
#include "./off"
#endif

bool  xnor(in bool  a, in bool  b) { return off(xor(a, b)); }
bvec2 xnor(in bvec2 a, in bvec2 b) { return off(xor(a, b)); }
bvec3 xnor(in bvec3 a, in bvec3 b) { return off(xor(a, b)); }
bvec4 xnor(in bvec4 a, in bvec4 b) { return off(xor(a, b)); }

bool  xnor(in int   a, in int   b) { return off(xor(a, b)); }
bvec2 xnor(in ivec2 a, in ivec2 b) { return off(xor(a, b)); }
bvec3 xnor(in ivec3 a, in ivec3 b) { return off(xor(a, b)); }
bvec4 xnor(in ivec4 a, in ivec4 b) { return off(xor(a, b)); }

bool  xnor(in float a, in float b) { return off(xor(a, b)); }
bvec2 xnor(in vec2  a, in vec2  b) { return off(xor(a, b)); }
bvec3 xnor(in vec3  a, in vec3  b) { return off(xor(a, b)); }
bvec4 xnor(in vec4  a, in vec4  b) { return off(xor(a, b)); }

#endif