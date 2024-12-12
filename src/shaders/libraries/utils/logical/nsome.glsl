#ifndef NSOME
#define NSOME

#ifndef SOME
#include "./some"
#endif

float nsome(in bool  a) { return 1.0 - some(a); }
float nsome(in bvec2 a) { return 1.0 - some(a); }
float nsome(in bvec3 a) { return 1.0 - some(a); }
float nsome(in bvec4 a) { return 1.0 - some(a); }
float nsome(in float a) { return 1.0 - some(a); }
float nsome(in vec2  a) { return 1.0 - some(a); }
float nsome(in vec3  a) { return 1.0 - some(a); }
float nsome(in vec4  a) { return 1.0 - some(a); }

#endif