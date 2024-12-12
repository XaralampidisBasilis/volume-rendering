#ifndef INSIDE_CLOSED
#define INSIDE_CLOSED

#ifndef AND
#include "../logical/and"
#endif

float inside_closed(in float a, in float b, in float x) { return and(x >= a, x <= b); }
vec2  inside_closed(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec3  inside_closed(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec4  inside_closed(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec2  inside_closed(in float a, in float b, in vec2  x) { return and(greaterThanEqual(x, vec2(a)), lessThanEqual(x, vec2(b))); }
vec3  inside_closed(in float a, in float b, in vec3  x) { return and(greaterThanEqual(x, vec3(a)), lessThanEqual(x, vec3(b))); }
vec4  inside_closed(in float a, in float b, in vec4  x) { return and(greaterThanEqual(x, vec4(a)), lessThanEqual(x, vec4(b))); }

// float inside_closed(in float a, in float b, in float x) { return step(a, x) * step(x, b); }
// vec2  inside_closed(in vec2  a, in vec2  b, in vec2  x) { return step(a, x) * step(x, b); }
// vec3  inside_closed(in vec3  a, in vec3  b, in vec3  x) { return step(a, x) * step(x, b); }
// vec4  inside_closed(in vec4  a, in vec4  b, in vec4  x) { return step(a, x) * step(x, b); }
// vec2  inside_closed(in float a, in float b, in vec2  x) { return step(a, x) * step(x, vec2(b)); }
// vec3  inside_closed(in float a, in float b, in vec3  x) { return step(a, x) * step(x, vec3(b)); }
// vec4  inside_closed(in float a, in float b, in vec4  x) { return step(a, x) * step(x, vec4(b)); }


#endif 