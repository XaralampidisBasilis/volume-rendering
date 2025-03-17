#ifndef INSIDE_CLOSED_OPEN
#define INSIDE_CLOSED_OPEN

#ifndef AND
#include "../logical/and"
#endif

bool   inside_closed_open(in float a, in float b, in float x) { return and(x >= a, x < b); }
bvec2  inside_closed_open(in float a, in float b, in vec2  x) { return and(greaterThanEqual(x, vec2(a)), lessThan(x, vec2(b))); }
bvec3  inside_closed_open(in float a, in float b, in vec3  x) { return and(greaterThanEqual(x, vec3(a)), lessThan(x, vec3(b))); }
bvec4  inside_closed_open(in float a, in float b, in vec4  x) { return and(greaterThanEqual(x, vec4(a)), lessThan(x, vec4(b))); }
bvec2  inside_closed_open(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }
bvec3  inside_closed_open(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }
bvec4  inside_closed_open(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }

bool   inside_closed_open(in int   a, in int   b, in int   x) { return and(x >= a, x < b); }
bvec2  inside_closed_open(in int   a, in int   b, in ivec2 x) { return and(greaterThanEqual(x, ivec2(a)), lessThan(x, ivec2(b))); }
bvec3  inside_closed_open(in int   a, in int   b, in ivec3 x) { return and(greaterThanEqual(x, ivec3(a)), lessThan(x, ivec3(b))); }
bvec4  inside_closed_open(in int   a, in int   b, in ivec4 x) { return and(greaterThanEqual(x, ivec4(a)), lessThan(x, ivec4(b))); }
bvec2  inside_closed_open(in ivec2 a, in ivec2 b, in ivec2 x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }
bvec3  inside_closed_open(in ivec3 a, in ivec3 b, in ivec3 x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }
bvec4  inside_closed_open(in ivec4 a, in ivec4 b, in ivec4 x) { return and(greaterThanEqual(x, a), lessThan(x, b)); }

#endif 
