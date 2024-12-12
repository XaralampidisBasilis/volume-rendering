#ifndef SOME
#define SOME

#ifndef MMAX
#include "../MMAX"
#endif
#ifndef ON
#include "./on"
#endif

float some(in bool  a) { return mmax(on(a)); }
float some(in bvec2 a) { return mmax(on(a)); }
float some(in bvec3 a) { return mmax(on(a)); }
float some(in bvec4 a) { return mmax(on(a)); }
float some(in float a) { return mmax(on(a)); }
float some(in vec2  a) { return mmax(on(a)); }
float some(in vec3  a) { return mmax(on(a)); }
float some(in vec4  a) { return mmax(on(a)); }

#endif
