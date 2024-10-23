#ifndef INSIDE_BOX_INCLUSIVE
#define INSIDE_BOX_INCLUSIVE

float inside_box_inclusive(in vec2  b_min, vec2  b_max, in vec2  p) {return mmin(inside_inclusive(b_min, b_max, p)); }
float inside_box_inclusive(in vec3  b_min, vec3  b_max, in vec3  p) {return mmin(inside_inclusive(b_min, b_max, p)); }
float inside_box_inclusive(in vec4  b_min, vec4  b_max, in vec4  p) {return mmin(inside_inclusive(b_min, b_max, p)); }
float inside_box_inclusive(in float b_min, float b_max, in vec2  p) {return mmin(inside_inclusive(b_min, b_max, p)); }
float inside_box_inclusive(in float b_min, float b_max, in vec3  p) {return mmin(inside_inclusive(b_min, b_max, p)); }
float inside_box_inclusive(in float b_min, float b_max, in vec4  p) {return mmin(inside_inclusive(b_min, b_max, p)); }

#endif // INSIDE_BOX_INCLUSIVE