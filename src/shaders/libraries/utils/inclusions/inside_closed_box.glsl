#ifndef INSIDE_CLOSED_BOX
#define INSIDE_CLOSED_BOX

#ifndef EVERY
#include "../logical/every"
#endif
#ifndef INSIDE_CLOSED
#include "./inside_closed"
#endif

float inside_closed_box(in float a, float b, in float x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in vec2  a, vec2  b, in vec2  x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in vec3  a, vec3  b, in vec3  x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in vec4  a, vec4  b, in vec4  x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec2  x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec3  x) {return every(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec4  x) {return every(inside_closed(a, b, x)); }

#endif 