#ifndef OFF
#define OFF

#ifndef ON
#include "./on"
#endif

float off(in bool  a) { return 1.0 - on(a); }
vec2  off(in bvec2 a) { return 1.0 - on(a); }
vec3  off(in bvec3 a) { return 1.0 - on(a); }
vec4  off(in bvec4 a) { return 1.0 - on(a); }
float off(in float a) { return 1.0 - on(a); }
vec2  off(in vec2  a) { return 1.0 - on(a); }
vec3  off(in vec3  a) { return 1.0 - on(a); }
vec4  off(in vec4  a) { return 1.0 - on(a); }

#endif