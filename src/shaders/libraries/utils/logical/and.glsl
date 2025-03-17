#ifndef AND
#define AND

#ifndef ON
#include "./on"
#endif

bool  and(in bool  a, in bool  b) { return a && b; }
bvec2 and(in bvec2 a, in bvec2 b) { return bvec2(uvec2(a) & uvec2(b)); }
bvec3 and(in bvec3 a, in bvec3 b) { return bvec3(uvec3(a) & uvec3(b)); }
bvec4 and(in bvec4 a, in bvec4 b) { return bvec4(uvec4(a) & uvec4(b)); }

bool  and(in int   a, in int   b) { return and(on(a), on(b)); }
bvec2 and(in ivec2 a, in ivec2 b) { return and(on(a), on(b)); }
bvec3 and(in ivec3 a, in ivec3 b) { return and(on(a), on(b)); }
bvec4 and(in ivec4 a, in ivec4 b) { return and(on(a), on(b)); }

bool  and(in float a, in float b) { return and(on(a), on(b)); }
bvec2 and(in vec2  a, in vec2  b) { return and(on(a), on(b)); }
bvec3 and(in vec3  a, in vec3  b) { return and(on(a), on(b)); }
bvec4 and(in vec4  a, in vec4  b) { return and(on(a), on(b)); }

#endif