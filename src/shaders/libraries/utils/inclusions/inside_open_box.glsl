#ifndef INSIDE_OPEN_BOX
#define INSIDE_OPEN_BOX

#ifndef INSIDE_OPEN
#include "./inside_open"
#endif

bool inside_open_box(in float a, in float b, in float x) { return     inside_open(a, b, x) ; }
bool inside_open_box(in float a, in float b, in vec2  x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in float a, in float b, in vec3  x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in float a, in float b, in vec4  x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in vec2  a, in vec2  b, in vec2  x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in vec3  a, in vec3  b, in vec3  x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in vec4  a, in vec4  b, in vec4  x) { return all(inside_open(a, b, x)); }

bool inside_open_box(in int   a, in int   b, in int   x) { return     inside_open(a, b, x) ; }
bool inside_open_box(in int   a, in int   b, in ivec2 x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in int   a, in int   b, in ivec3 x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in int   a, in int   b, in ivec4 x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in ivec2 a, in ivec2 b, in ivec2 x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in ivec3 a, in ivec3 b, in ivec3 x) { return all(inside_open(a, b, x)); }
bool inside_open_box(in ivec4 a, in ivec4 b, in ivec4 x) { return all(inside_open(a, b, x)); }

#endif 