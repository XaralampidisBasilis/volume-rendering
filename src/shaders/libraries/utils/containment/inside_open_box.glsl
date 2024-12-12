#ifndef INSIDE_OPEN_BOX
#define INSIDE_OPEN_BOX

#ifndef EVERY
#include "../logical/every"
#endif
#ifndef INSIDE_OPEN
#include "./inside_open"
#endif

float inside_open_box(in float a, float b, in float x) {return every(inside_open(a, b, x)); }
float inside_open_box(in vec2  a, vec2  b, in vec2  x) {return every(inside_open(a, b, x)); }
float inside_open_box(in vec3  a, vec3  b, in vec3  x) {return every(inside_open(a, b, x)); }
float inside_open_box(in vec4  a, vec4  b, in vec4  x) {return every(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec2  x) {return every(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec3  x) {return every(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec4  x) {return every(inside_open(a, b, x)); }

#endif 