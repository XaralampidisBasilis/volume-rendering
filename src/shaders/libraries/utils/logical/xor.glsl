#ifndef XOR
#define XOR

#ifndef ON
#include "./on"
#endif


bool  xor(in bool  a, in bool  b) { return a ^^ b; }
bvec2 xor(in bvec2 a, in bvec2 b) { return bvec2(uvec2(a) ^ uvec2(b)); }
bvec3 xor(in bvec3 a, in bvec3 b) { return bvec3(uvec3(a) ^ uvec3(b)); }
bvec4 xor(in bvec4 a, in bvec4 b) { return bvec4(uvec4(a) ^ uvec4(b)); }

bool  xor(in int   a, in int   b) { return xor(on(a), on(b)); }
bvec2 xor(in ivec2 a, in ivec2 b) { return xor(on(a), on(b)); }
bvec3 xor(in ivec3 a, in ivec3 b) { return xor(on(a), on(b)); }
bvec4 xor(in ivec4 a, in ivec4 b) { return xor(on(a), on(b)); }

bool  xor(in float a, in float b) { return xor(on(a), on(b)); }
bvec2 xor(in vec2  a, in vec2  b) { return xor(on(a), on(b)); }
bvec3 xor(in vec3  a, in vec3  b) { return xor(on(a), on(b)); }
bvec4 xor(in vec4  a, in vec4  b) { return xor(on(a), on(b)); }

#endif