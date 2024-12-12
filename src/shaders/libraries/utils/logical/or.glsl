#ifndef OR
#define OR

#ifndef ON
#include "./on"
#endif

float or(in bool  a, in bool  b) { return max(on(a), on(b)); }
vec2  or(in bvec2 a, in bvec2 b) { return max(on(a), on(b)); }
vec3  or(in bvec3 a, in bvec3 b) { return max(on(a), on(b)); }
vec4  or(in bvec4 a, in bvec4 b) { return max(on(a), on(b)); }
float or(in float a, in float b) { return max(on(a), on(b)); }
vec2  or(in vec2  a, in vec2  b) { return max(on(a), on(b)); }
vec3  or(in vec3  a, in vec3  b) { return max(on(a), on(b)); }
vec4  or(in vec4  a, in vec4  b) { return max(on(a), on(b)); }

#endif