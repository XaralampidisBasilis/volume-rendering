#ifndef UTILS_INSIDE_BOX
#define UTILS_INSIDE_BOX

float inside_box(in vec2  b_min, vec2  b_max, in vec2  p) {return prod(inside(b_min, b_max, p)); }
float inside_box(in vec3  b_min, vec3  b_max, in vec3  p) {return prod(inside(b_min, b_max, p)); }
float inside_box(in vec4  b_min, vec4  b_max, in vec4  p) {return prod(inside(b_min, b_max, p)); }

float inside_box(in float b_min, float b_max, in vec2  p) {return prod(inside(b_min, b_max, p)); }
float inside_box(in float b_min, float b_max, in vec3  p) {return prod(inside(b_min, b_max, p)); }
float inside_box(in float b_min, float b_max, in vec4  p) {return prod(inside(b_min, b_max, p)); }

#endif