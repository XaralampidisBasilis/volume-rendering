#ifndef CONTAINMENT
#define CONTAINMENT

#ifndef LOGICAL
#include "./logical"
#endif
#ifndef PROD
#include "./prod"
#endif
#ifndef MMAX
#include "./mmax"
#endif

#ifndef INSIDE_CLOSED
#define INSIDE_CLOSED

float inside_closed(in float a, in float b, in float x) { return and(x >= a, x <= b); }
vec2  inside_closed(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec3  inside_closed(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec4  inside_closed(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThanEqual(x, a), lessThanEqual(x, b)); }
vec2  inside_closed(in float a, in float b, in vec2  x) { return and(greaterThanEqual(x, vec2(a)), lessThanEqual(x, vec2(b))); }
vec3  inside_closed(in float a, in float b, in vec3  x) { return and(greaterThanEqual(x, vec3(a)), lessThanEqual(x, vec3(b))); }
vec4  inside_closed(in float a, in float b, in vec4  x) { return and(greaterThanEqual(x, vec4(a)), lessThanEqual(x, vec4(b))); }

#endif 

#ifndef OUTSIDE_CLOSED
#define OUTSIDE_CLOSED

float outside_closed(in float a, in float b, in float x) { return or(x <= a, x >= b); }
vec2  outside_closed(in vec2  a, in vec2  b, in vec2  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
vec3  outside_closed(in vec3  a, in vec3  b, in vec3  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
vec4  outside_closed(in vec4  a, in vec4  b, in vec4  x) { return or(lessThanEqual(x, a), greaterThanEqual(x, b)); }
vec2  outside_closed(in float a, in float b, in vec2  x) { return or(lessThanEqual(x, vec2(a)), greaterThanEqual(x, vec2(b))); }
vec3  outside_closed(in float a, in float b, in vec3  x) { return or(lessThanEqual(x, vec3(a)), greaterThanEqual(x, vec3(b))); }
vec4  outside_closed(in float a, in float b, in vec4  x) { return or(lessThanEqual(x, vec4(a)), greaterThanEqual(x, vec4(b))); }

#endif 

#ifndef INSIDE_OPEN
#define INSIDE_OPEN

float inside_open(in float a, in float b, in float x) { return and(x > a, x < b); }
vec2  inside_open(in vec2  a, in vec2  b, in vec2  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec3  inside_open(in vec3  a, in vec3  b, in vec3  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec4  inside_open(in vec4  a, in vec4  b, in vec4  x) { return and(greaterThan(x, a), lessThan(x, b)); }
vec2  inside_open(in float a, in float b, in vec2  x) { return and(greaterThan(x, vec2(a)), lessThan(x, vec2(b))); }
vec3  inside_open(in float a, in float b, in vec3  x) { return and(greaterThan(x, vec3(a)), lessThan(x, vec3(b))); }
vec4  inside_open(in float a, in float b, in vec4  x) { return and(greaterThan(x, vec4(a)), lessThan(x, vec4(b))); }

#endif 

#ifndef OUTSIDE_OPEN
#define OUTSIDE_OPEN

float outside_open(in float a, in float b, in float x) { return or(x < a, x > b); }
vec2  outside_open(in vec2  a, in vec2  b, in vec2  x) { return or(lessThan(x, a), greaterThan(x, b)); }
vec3  outside_open(in vec3  a, in vec3  b, in vec3  x) { return or(lessThan(x, a), greaterThan(x, b)); }
vec4  outside_open(in vec4  a, in vec4  b, in vec4  x) { return or(lessThan(x, a), greaterThan(x, b)); }
vec2  outside_open(in float a, in float b, in vec2  x) { return or(lessThan(x, vec2(a)), greaterThan(x, vec2(b))); }
vec3  outside_open(in float a, in float b, in vec3  x) { return or(lessThan(x, vec3(a)), greaterThan(x, vec3(b))); }
vec4  outside_open(in float a, in float b, in vec4  x) { return or(lessThan(x, vec4(a)), greaterThan(x, vec4(b))); }

#endif 

#ifndef OUTSIDE_CLOSED_BOX
#define OUTSIDE_CLOSED_BOX

float outside_closed_box(in float a, float b, in float x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in vec2  a, vec2  b, in vec2  x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in vec3  a, vec3  b, in vec3  x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in vec4  a, vec4  b, in vec4  x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec2  x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec3  x) {return mmax(outside_closed(a, b, x)); }
float outside_closed_box(in float a, float b, in vec4  x) {return mmax(outside_closed(a, b, x)); }

#endif 

#ifndef INSIDE_CLOSED_BOX
#define INSIDE_CLOSED_BOX

float inside_closed_box(in float a, float b, in float x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in vec2  a, vec2  b, in vec2  x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in vec3  a, vec3  b, in vec3  x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in vec4  a, vec4  b, in vec4  x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec2  x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec3  x) {return prod(inside_closed(a, b, x)); }
float inside_closed_box(in float a, float b, in vec4  x) {return prod(inside_closed(a, b, x)); }

#endif 

#ifndef OUTSIDE_OPEN_BOX
#define OUTSIDE_OPEN_BOX

float outside_open_box(in float a, float b, in float x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in vec2  a, vec2  b, in vec2  x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in vec3  a, vec3  b, in vec3  x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in vec4  a, vec4  b, in vec4  x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in float a, float b, in vec2  x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in float a, float b, in vec3  x) {return mmax(outside_open(a, b, x)); }
float outside_open_box(in float a, float b, in vec4  x) {return mmax(outside_open(a, b, x)); }

#endif 

#ifndef INSIDE_OPEN_BOX
#define INSIDE_OPEN_BOX

float inside_open_box(in float a, float b, in float x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in vec2  a, vec2  b, in vec2  x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in vec3  a, vec3  b, in vec3  x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in vec4  a, vec4  b, in vec4  x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec2  x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec3  x) {return prod(inside_open(a, b, x)); }
float inside_open_box(in float a, float b, in vec4  x) {return prod(inside_open(a, b, x)); }

#endif 


#endif
