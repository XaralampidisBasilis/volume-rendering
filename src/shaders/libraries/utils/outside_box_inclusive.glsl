#ifndef OUTSIDE_BOX_INCLUSIVE
#define OUTSIDE_BOX_INCLUSIVE

#ifndef MMAX
#include "./mmax"
#endif

#ifndef OUTSIDE_INCLUSIVE
#include "./outside_inclusive"
#endif

float outside_box_inclusive(in vec2  b_min, vec2  b_max, in vec2 p) {return mmax(outside_inclusive(b_min, b_max, p)); }
float outside_box_inclusive(in vec3  b_min, vec3  b_max, in vec3 p) {return mmax(outside_inclusive(b_min, b_max, p)); }
float outside_box_inclusive(in vec4  b_min, vec4  b_max, in vec4 p) {return mmax(outside_inclusive(b_min, b_max, p)); }
float outside_box_inclusive(in float b_min, float b_max, in vec2 p) {return mmax(outside_inclusive(b_min, b_max, p)); }
float outside_box_inclusive(in float b_min, float b_max, in vec3 p) {return mmax(outside_inclusive(b_min, b_max, p)); }
float outside_box_inclusive(in float b_min, float b_max, in vec4 p) {return mmax(outside_inclusive(b_min, b_max, p)); }

#endif // OUTSIDE_BOX_INCLUSIVE
