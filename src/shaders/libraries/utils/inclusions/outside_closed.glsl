#ifndef OUTSIDE_CLOSED
#define OUTSIDE_CLOSED

#ifndef INSIDE_CLOSED
#include "./inside_closed"
#endif

float outside_closed(in float a, in float b, in float x) { return 1.0 - inside_closed(a, b, x); }
vec2  outside_closed(in vec2  a, in vec2  b, in vec2  x) { return 1.0 - inside_closed(a, b, x); }
vec3  outside_closed(in vec3  a, in vec3  b, in vec3  x) { return 1.0 - inside_closed(a, b, x); }
vec4  outside_closed(in vec4  a, in vec4  b, in vec4  x) { return 1.0 - inside_closed(a, b, x); }
vec2  outside_closed(in float a, in float b, in vec2  x) { return 1.0 - inside_closed(a, b, x); }
vec3  outside_closed(in float a, in float b, in vec3  x) { return 1.0 - inside_closed(a, b, x); }
vec4  outside_closed(in float a, in float b, in vec4  x) { return 1.0 - inside_closed(a, b, x); }

// float outside_closed(in float a, in float b, in float x) { return max(step(x, a), step(b, x)); }
// vec2  outside_closed(in vec2  a, in vec2  b, in vec2  x) { return max(step(x, a), step(b, x)); }
// vec3  outside_closed(in vec3  a, in vec3  b, in vec3  x) { return max(step(x, a), step(b, x)); }
// vec4  outside_closed(in vec4  a, in vec4  b, in vec4  x) { return max(step(x, a), step(b, x)); }
// vec2  outside_closed(in float a, in float b, in vec2  x) { return max(step(x, vec2(a)), step(b, x)); }
// vec3  outside_closed(in float a, in float b, in vec3  x) { return max(step(x, vec3(a)), step(b, x)); }
// vec4  outside_closed(in float a, in float b, in vec4  x) { return max(step(x, vec4(a)), step(b, x)); }

#endif 