#ifndef EVERY
#define EVERY

#ifndef PROD
#include "../prod"
#endif
#ifndef ON
#include "./on"
#endif

float every(in bool  a) { return prod(on(a)); }
float every(in bvec2 a) { return prod(on(a)); }
float every(in bvec3 a) { return prod(on(a)); }
float every(in bvec4 a) { return prod(on(a)); }
float every(in float a) { return prod(on(a)); }
float every(in vec2  a) { return prod(on(a)); }
float every(in vec3  a) { return prod(on(a)); }
float every(in vec4  a) { return prod(on(a)); }

#endif