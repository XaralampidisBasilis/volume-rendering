#ifndef ON
#define ON

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

float on(in bool  a) { return float(a); }
vec2  on(in bvec2 a) { return vec2( a); }
vec3  on(in bvec3 a) { return vec3( a); }
vec4  on(in bvec4 a) { return vec4( a); }
float on(in float a) { return on(abs(a) > MICRO_TOLERANCE); }
vec2  on(in vec2  a) { return on(greaterThan(abs(a), vec2(MICRO_TOLERANCE))); }
vec3  on(in vec3  a) { return on(greaterThan(abs(a), vec3(MICRO_TOLERANCE))); }
vec4  on(in vec4  a) { return on(greaterThan(abs(a), vec4(MICRO_TOLERANCE))); }

#endif