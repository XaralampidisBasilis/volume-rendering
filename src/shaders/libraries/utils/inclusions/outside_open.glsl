#ifndef OUTSIDE_OPEN
#define OUTSIDE_OPEN

#ifndef OR
#include "../logical/or"
#endif

bool   outside_open(in float a, in float b, in float x) { return or(x < a, x > b); }
bvec2  outside_open(in float a, in float b, in vec2  x) { return or(lessThan(x, vec2(a)), greaterThan(x, vec2(b))); }
bvec3  outside_open(in float a, in float b, in vec3  x) { return or(lessThan(x, vec3(a)), greaterThan(x, vec3(b))); }
bvec4  outside_open(in float a, in float b, in vec4  x) { return or(lessThan(x, vec4(a)), greaterThan(x, vec4(b))); }
bvec2  outside_open(in vec2  a, in vec2  b, in vec2  x) { return or(lessThan(x, a), greaterThan(x, b)); }
bvec3  outside_open(in vec3  a, in vec3  b, in vec3  x) { return or(lessThan(x, a), greaterThan(x, b)); }
bvec4  outside_open(in vec4  a, in vec4  b, in vec4  x) { return or(lessThan(x, a), greaterThan(x, b)); }

bool   outside_open(in int   a, in int   b, in int   x) { return or(x > a, x < b); }
bvec2  outside_open(in int   a, in int   b, in ivec2 x) { return or(lessThan(x, ivec2(a)), greaterThan(x, ivec2(b))); }
bvec3  outside_open(in int   a, in int   b, in ivec3 x) { return or(lessThan(x, ivec3(a)), greaterThan(x, ivec3(b))); }
bvec4  outside_open(in int   a, in int   b, in ivec4 x) { return or(lessThan(x, ivec4(a)), greaterThan(x, ivec4(b))); }
bvec2  outside_open(in ivec2 a, in ivec2 b, in ivec2 x) { return or(lessThan(x, a), greaterThan(x, b)); }
bvec3  outside_open(in ivec3 a, in ivec3 b, in ivec3 x) { return or(lessThan(x, a), greaterThan(x, b)); }
bvec4  outside_open(in ivec4 a, in ivec4 b, in ivec4 x) { return or(lessThan(x, a), greaterThan(x, b)); }

#endif 