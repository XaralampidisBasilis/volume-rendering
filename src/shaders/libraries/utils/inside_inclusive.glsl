#ifndef INSIDE_INCLUSIVE
#define INSIDE_INCLUSIVE

float inside_inclusive(in float a, in float b, in float v) { return step(a, v) * step(v, b); }
vec2  inside_inclusive(in vec2  a, in vec2  b, in vec2  v) { return step(a, v) * step(v, b); }
vec3  inside_inclusive(in vec3  a, in vec3  b, in vec3  v) { return step(a, v) * step(v, b); }
vec4  inside_inclusive(in vec4  a, in vec4  b, in vec4  v) { return step(a, v) * step(v, b); }
vec2  inside_inclusive(in float a, in float b, in vec2  v) { return step(a, v) * step(v, vec2(b)); }
vec3  inside_inclusive(in float a, in float b, in vec3  v) { return step(a, v) * step(v, vec3(b)); }
vec4  inside_inclusive(in float a, in float b, in vec4  v) { return step(a, v) * step(v, vec4(b)); }

#endif // INSIDE_INCLUSIVE