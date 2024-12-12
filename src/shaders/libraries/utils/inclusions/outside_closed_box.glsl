#ifndef OUTSIDE_CLOSED_BOX
#define OUTSIDE_CLOSED_BOX

#ifndef SOME
#include "../logical/some"
#endif
#ifndef OUTSIDE_CLOSED
#include "./outside_closed"
#endif

float outside_closed_box(in float a, float b, in float x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in vec2  a, vec2  b, in vec2  x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in vec3  a, vec3  b, in vec3  x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in vec4  a, vec4  b, in vec4  x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec2  x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec3  x) {return some(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec4  x) {return some(outside_closed(a, b, x)); }

#endif 