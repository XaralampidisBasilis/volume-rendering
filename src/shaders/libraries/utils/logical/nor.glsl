#ifndef NOR
#define NOR

#ifndef OR
#include "./or"
#endif
#ifndef OFF
#include "./off"
#endif

bool  nor(in bool  a, in bool  b) { return off(or(a, b)); }
bvec2 nor(in bvec2 a, in bvec2 b) { return off(or(a, b)); }
bvec3 nor(in bvec3 a, in bvec3 b) { return off(or(a, b)); }
bvec4 nor(in bvec4 a, in bvec4 b) { return off(or(a, b)); }

bool  nor(in int   a, in int   b) { return off(or(a, b)); }
bvec2 nor(in ivec2 a, in ivec2 b) { return off(or(a, b)); }
bvec3 nor(in ivec3 a, in ivec3 b) { return off(or(a, b)); }
bvec4 nor(in ivec4 a, in ivec4 b) { return off(or(a, b)); }

bool  nor(in float a, in float b) { return off(or(a, b)); }
bvec2 nor(in vec2  a, in vec2  b) { return off(or(a, b)); }
bvec3 nor(in vec3  a, in vec3  b) { return off(or(a, b)); }
bvec4 nor(in vec4  a, in vec4  b) { return off(or(a, b)); }

#endif