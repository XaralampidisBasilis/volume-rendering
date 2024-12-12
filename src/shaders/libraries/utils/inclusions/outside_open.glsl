#ifndef OUTSIDE_OPEN
#define OUTSIDE_OPEN

#ifndef INSIDE_OPEN
#include "./inside_open"
#endif

float outside_open(in float a, in float b, in float x) { return 1.0 - inside_open(a, b, x); }
vec2  outside_open(in vec2  a, in vec2  b, in vec2  x) { return 1.0 - inside_open(a, b, x); }
vec3  outside_open(in vec3  a, in vec3  b, in vec3  x) { return 1.0 - inside_open(a, b, x); }
vec4  outside_open(in vec4  a, in vec4  b, in vec4  x) { return 1.0 - inside_open(a, b, x); }
vec2  outside_open(in float a, in float b, in vec2  x) { return 1.0 - inside_open(a, b, x); }
vec3  outside_open(in float a, in float b, in vec3  x) { return 1.0 - inside_open(a, b, x); }
vec4  outside_open(in float a, in float b, in vec4  x) { return 1.0 - inside_open(a, b, x); }

#endif 