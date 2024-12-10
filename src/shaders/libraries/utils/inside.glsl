#ifndef INSIDE
#define INSIDE

float inside(in float a, in float b, in float v) { return 1.0 - max(step(v, a), step(b, v)); }
vec2  inside(in vec2  a, in vec2  b, in vec2  v) { return 1.0 - max(step(v, a), step(b, v)); }
vec3  inside(in vec3  a, in vec3  b, in vec3  v) { return 1.0 - max(step(v, a), step(b, v)); }
vec4  inside(in vec4  a, in vec4  b, in vec4  v) { return 1.0 - max(step(v, a), step(b, v)); }
vec2  inside(in float a, in float b, in vec2  v) { return 1.0 - max(step(v, vec2(a)), step(vec2(b), v)); }
vec3  inside(in float a, in float b, in vec3  v) { return 1.0 - max(step(v, vec3(a)), step(vec3(b), v)); }
vec4  inside(in float a, in float b, in vec4  v) { return 1.0 - max(step(v, vec4(a)), step(vec4(b), v)); }

#endif // INSIDE