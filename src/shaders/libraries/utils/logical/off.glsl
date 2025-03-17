#ifndef OFF
#define OFF

#ifndef ON
#include "./on"
#endif

bool  off(in bool  a)  { return !a ; }
bvec2 off(in bvec2 a)  { return not(a); }
bvec3 off(in bvec3 a)  { return not(a); }
bvec4 off(in bvec4 a)  { return not(a); }

bool  off(in int   a)  { return !on(a) ; }
bvec2 off(in ivec2 a)  { return not(on(a)); }
bvec3 off(in ivec3 a)  { return not(on(a)); }
bvec4 off(in ivec4 a)  { return not(on(a)); }

bool  off(in float a) { return !on(a) ; }
bvec2 off(in vec2  a) { return not(on(a)); }
bvec3 off(in vec3  a) { return not(on(a)); }
bvec4 off(in vec4  a) { return not(on(a)); }

#endif