#ifndef INSIDE_OPEN
#define INSIDE_OPEN

#ifndef AND
#include "../logical/and"
#endif

float inside_open(in float a, in float b, in float x) { return and(x > a, x < b); }
vec2  inside_open(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec3  inside_open(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec4  inside_open(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec2  inside_open(in float a, in float b, in vec2  x) { return and(greaterThan(x, vec2(a)), lessThan(x, vec2(b))); }
vec3  inside_open(in float a, in float b, in vec3  x) { return and(greaterThan(x, vec3(a)), lessThan(x, vec3(b))); }
vec4  inside_open(in float a, in float b, in vec4  x) { return and(greaterThan(x, vec4(a)), lessThan(x, vec4(b))); }

#endif 
