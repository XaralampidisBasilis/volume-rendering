#ifndef XOR
#define XOR

#ifndef ON
#include "./on"
#endif

float xor(in bool  a, in bool  b) { return abs(on(a) - on(b)); }
vec2  xor(in bvec2 a, in bvec2 b) { return abs(on(a) - on(b)); }
vec3  xor(in bvec3 a, in bvec3 b) { return abs(on(a) - on(b)); }
vec4  xor(in bvec4 a, in bvec4 b) { return abs(on(a) - on(b)); }
float xor(in float a, in float b) { return abs(on(a) - on(b)); }
vec2  xor(in vec2  a, in vec2  b) { return abs(on(a) - on(b)); }
vec3  xor(in vec3  a, in vec3  b) { return abs(on(a) - on(b)); }
vec4  xor(in vec4  a, in vec4  b) { return abs(on(a) - on(b)); }

#endif