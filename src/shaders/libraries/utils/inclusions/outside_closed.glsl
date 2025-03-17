#ifndef OUTSIDE_CLOSED
#define OUTSIDE_CLOSED

#ifndef OR
#include "../logical/or"
#endif

bool   outside_closed(in float a, in float b, in float x) { return or(x <= a, x >= b); }
bvec2  outside_closed(in float a, in float b, in vec2  x) { return or(lessThanEqual(x, vec2(a)), greaterThanEqual(x, vec2(b))); }
bvec3  outside_closed(in float a, in float b, in vec3  x) { return or(lessThanEqual(x, vec3(a)), greaterThanEqual(x, vec3(b))); }
bvec4  outside_closed(in float a, in float b, in vec4  x) { return or(lessThanEqual(x, vec4(a)), greaterThanEqual(x, vec4(b))); }
bvec2  outside_closed(in vec2  a, in vec2  b, in vec2  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
bvec3  outside_closed(in vec3  a, in vec3  b, in vec3  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
bvec4  outside_closed(in vec4  a, in vec4  b, in vec4  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }

bool   outside_closed(in int   a, in int   b, in int   x) { return or(x >= a, x <= b); }
bvec2  outside_closed(in int   a, in int   b, in ivec2 x) { return or(lessThanEqual(x, ivec2(a)), greaterThanEqual(x, ivec2(b))); }
bvec3  outside_closed(in int   a, in int   b, in ivec3 x) { return or(lessThanEqual(x, ivec3(a)), greaterThanEqual(x, ivec3(b))); }
bvec4  outside_closed(in int   a, in int   b, in ivec4 x) { return or(lessThanEqual(x, ivec4(a)), greaterThanEqual(x, ivec4(b))); }
bvec2  outside_closed(in ivec2 a, in ivec2 b, in ivec2 x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
bvec3  outside_closed(in ivec3 a, in ivec3 b, in ivec3 x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
bvec4  outside_closed(in ivec4 a, in ivec4 b, in ivec4 x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }


#endif 