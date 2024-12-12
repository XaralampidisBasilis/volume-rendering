#ifndef AND
#define AND

#ifndef ON
#include "./on"
#endif

float and(in bool  a, in bool  b) { return on(a) * on(b); }
vec2  and(in bvec2 a, in bvec2 b) { return on(a) * on(b); }
vec3  and(in bvec3 a, in bvec3 b) { return on(a) * on(b); }
vec4  and(in bvec4 a, in bvec4 b) { return on(a) * on(b); }
float and(in float a, in float b) { return on(a) * on(b); }
vec2  and(in vec2  a, in vec2  b) { return on(a) * on(b); }
vec3  and(in vec3  a, in vec3  b) { return on(a) * on(b); }
vec4  and(in vec4  a, in vec4  b) { return on(a) * on(b); }

#endif