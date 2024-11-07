#ifndef OUTSIDE
#define OUTSIDE

float outside(in float a, in float b, in float v) { return 1.0 - inside_inclusive(a, b, v); }
vec2  outside(in vec2  a, in vec2  b, in vec2  v) { return 1.0 - inside_inclusive(a, b, v); }
vec3  outside(in vec3  a, in vec3  b, in vec3  v) { return 1.0 - inside_inclusive(a, b, v); }
vec4  outside(in vec4  a, in vec4  b, in vec4  v) { return 1.0 - inside_inclusive(a, b, v); }
vec2  outside(in float a, in float b, in vec2  v) { return 1.0 - inside_inclusive(a, b, v); }
vec3  outside(in float a, in float b, in vec3  v) { return 1.0 - inside_inclusive(a, b, v); }
vec4  outside(in float a, in float b, in vec4  v) { return 1.0 - inside_inclusive(a, b, v); }

#endif // OUTSIDE
