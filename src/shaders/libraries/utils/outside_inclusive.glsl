#ifndef OUTSIDE_INCLUSIVE
#define OUTSIDE_INCLUSIVE

float outside_inclusive(in float a, in float b, in float v) { return max(step(v, a), step(b, v)); }
vec2  outside_inclusive(in vec2  a, in vec2  b, in vec2  v) { return max(step(v, a), step(b, v)); }
vec3  outside_inclusive(in vec3  a, in vec3  b, in vec3  v) { return max(step(v, a), step(b, v)); }
vec4  outside_inclusive(in vec4  a, in vec4  b, in vec4  v) { return max(step(v, a), step(b, v)); }
vec2  outside_inclusive(in float a, in float b, in vec2  v) { return max(step(v, vec2(a)), step(b, v)); }
vec3  outside_inclusive(in float a, in float b, in vec3  v) { return max(step(v, vec3(a)), step(b, v)); }
vec4  outside_inclusive(in float a, in float b, in vec4  v) { return max(step(v, vec4(a)), step(b, v)); }

#endif // OUTSIDE_INCLUSIVE
