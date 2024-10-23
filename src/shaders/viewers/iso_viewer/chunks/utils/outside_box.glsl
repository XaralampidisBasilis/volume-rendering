#ifndef OUTSIDE_BOX
#define OUTSIDE_BOX

float outside_box(in vec2  b_min, vec2  b_max, in vec2 p) {return mmax(outside(b_min, b_max, p)); }
float outside_box(in vec3  b_min, vec3  b_max, in vec3 p) {return mmax(outside(b_min, b_max, p)); }
float outside_box(in vec4  b_min, vec4  b_max, in vec4 p) {return mmax(outside(b_min, b_max, p)); }
float outside_box(in float b_min, float b_max, in vec2 p) {return mmax(outside(b_min, b_max, p)); }
float outside_box(in float b_min, float b_max, in vec3 p) {return mmax(outside(b_min, b_max, p)); }
float outside_box(in float b_min, float b_max, in vec4 p) {return mmax(outside(b_min, b_max, p)); }

#endif // OUTSIDE_BOX