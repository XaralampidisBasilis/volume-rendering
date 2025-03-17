#ifndef ON
#define ON

bool  on(in bool  a) { return a; }
bvec2 on(in bvec2 a) { return a; }
bvec3 on(in bvec3 a) { return a; }
bvec4 on(in bvec4 a) { return a; }

bool  on(in int   a) { return bool (a); }
bvec2 on(in ivec2 a) { return bvec2(a); }
bvec3 on(in ivec3 a) { return bvec3(a); }
bvec4 on(in ivec4 a) { return bvec4(a); }

bool  on(in float a) { return on(abs(a) > 0.0); }
bvec2 on(in vec2  a) { return on(greaterThan(abs(a), vec2(0.0))); }
bvec3 on(in vec3  a) { return on(greaterThan(abs(a), vec3(0.0))); }
bvec4 on(in vec4  a) { return on(greaterThan(abs(a), vec4(0.0))); }

#endif