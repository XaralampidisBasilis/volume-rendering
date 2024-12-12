#ifndef CLAMPABS
#define CLAMPABS

#ifndef SSIGN
#include "./functions/ssign"
#endif

float clampabs(in float v, in float a, in float b) { return ssign(v) * clamp(abs(v), a, b); }
vec2  clampabs(in vec2  v, in float a, in float b) { return ssign(v) * clamp(abs(v), a, b); }
vec3  clampabs(in vec3  v, in float a, in float b) { return ssign(v) * clamp(abs(v), a, b); }
vec4  clampabs(in vec4  v, in float a, in float b) { return ssign(v) * clamp(abs(v), a, b); }
vec2  clampabs(in vec2  v, in vec2  a, in vec2  b) { return ssign(v) * clamp(abs(v), a, b); }
vec3  clampabs(in vec3  v, in vec3  a, in vec3  b) { return ssign(v) * clamp(abs(v), a, b); }
vec4  clampabs(in vec4  v, in vec4  a, in vec4  b) { return ssign(v) * clamp(abs(v), a, b); }

#endif // CLAMPABS
