#ifndef NEVERY
#define NEVERY

#ifndef EVERY
#include "./every"
#endif

float nevery(in bool  a) { return 1.0 - every(a); }
float nevery(in bvec2 a) { return 1.0 - every(a); }
float nevery(in bvec3 a) { return 1.0 - every(a); }
float nevery(in bvec4 a) { return 1.0 - every(a); }
float nevery(in float a) { return 1.0 - every(a); }
float nevery(in vec2  a) { return 1.0 - every(a); }
float nevery(in vec3  a) { return 1.0 - every(a); }
float nevery(in vec4  a) { return 1.0 - every(a); }

#endif