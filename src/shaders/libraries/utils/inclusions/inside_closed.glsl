#ifndef INSIDE_CLOSED
#define INSIDE_CLOSED

#ifndef AND
#include "../logical/and"
#endif

bool   inside_closed(in float a, in float b, in float x) { return and(x >= a, x <= b); }
bvec2  inside_closed(in float a, in float b, in vec2  x) { return and(greaterThanEqual(x, vec2(a)), lessThanEqual(x, vec2(b))); }
bvec3  inside_closed(in float a, in float b, in vec3  x) { return and(greaterThanEqual(x, vec3(a)), lessThanEqual(x, vec3(b))); }
bvec4  inside_closed(in float a, in float b, in vec4  x) { return and(greaterThanEqual(x, vec4(a)), lessThanEqual(x, vec4(b))); }
bvec2  inside_closed(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
bvec3  inside_closed(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
bvec4  inside_closed(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }

bool   inside_closed(in int   a, in int   b, in int   x) { return and(x >= a, x <= b); }
bvec2  inside_closed(in int   a, in int   b, in ivec2 x) { return and(greaterThanEqual(x, ivec2(a)), lessThanEqual(x, ivec2(b))); }
bvec3  inside_closed(in int   a, in int   b, in ivec3 x) { return and(greaterThanEqual(x, ivec3(a)), lessThanEqual(x, ivec3(b))); }
bvec4  inside_closed(in int   a, in int   b, in ivec4 x) { return and(greaterThanEqual(x, ivec4(a)), lessThanEqual(x, ivec4(b))); }
bvec2  inside_closed(in ivec2 a, in ivec2 b, in ivec2 x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
bvec3  inside_closed(in ivec3 a, in ivec3 b, in ivec3 x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
bvec4  inside_closed(in ivec4 a, in ivec4 b, in ivec4 x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }

#endif 