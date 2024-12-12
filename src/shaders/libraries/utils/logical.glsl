#ifndef LOGICAL
#define LOGICAL

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

#ifndef MMIN
#include "./mmin"
#endif

#ifndef MMAX
#include "./mmax"
#endif

#ifndef ON
#define ON

float on(in bool  a) { return float(a); }
vec2  on(in bvec2 a) { return vec2( a); }
vec3  on(in bvec3 a) { return vec3( a); }
vec4  on(in bvec4 a) { return vec4( a); }
float on(in float a) { return step(MICRO_TOLERANCE, abs(a)); }
vec2  on(in vec2  a) { return step(MICRO_TOLERANCE, abs(a)); }
vec3  on(in vec3  a) { return step(MICRO_TOLERANCE, abs(a)); }
vec4  on(in vec4  a) { return step(MICRO_TOLERANCE, abs(a)); }

#endif

#ifndef OFF
#define OFF

float off(in bool  a) { return 1.0 - on(a); }
vec2  off(in bvec2 a) { return 1.0 - on(a); }
vec3  off(in bvec3 a) { return 1.0 - on(a); }
vec4  off(in bvec4 a) { return 1.0 - on(a); }
float off(in float a) { return 1.0 - on(a); }
vec2  off(in vec2  a) { return 1.0 - on(a); }
vec3  off(in vec3  a) { return 1.0 - on(a); }
vec4  off(in vec4  a) { return 1.0 - on(a); }

#endif

#ifndef AND
#define AND

float and(in bool  a, in bool  b) { return float(a && b); }
vec2  and(in bvec2 a, in bvec2 b) { return vec2(a.x && b.x, a.y && b.y); }
vec3  and(in bvec3 a, in bvec3 b) { return vec3(a.x && b.x, a.y && b.y, a.z && b.z); }
vec4  and(in bvec4 a, in bvec4 b) { return vec4(a.x && b.x, a.y && b.y, a.z && b.z, a.w && b.w); }
float and(in float a, in float b) { return min(on(a), on(b)); }
vec2  and(in vec2  a, in vec2  b) { return min(on(a), on(b)); }
vec3  and(in vec3  a, in vec3  b) { return min(on(a), on(b)); }
vec4  and(in vec4  a, in vec4  b) { return min(on(a), on(b)); }

#endif

#ifndef OR
#define OR

float or(in bool  a, in bool  b) { return float(a || b); }
vec2  or(in bvec2 a, in bvec2 b) { return vec2(a.x || b.x, a.y || b.y); }
vec3  or(in bvec3 a, in bvec3 b) { return vec3(a.x || b.x, a.y || b.y, a.z || b.z); }
vec4  or(in bvec4 a, in bvec4 b) { return vec4(a.x || b.x, a.y || b.y, a.z || b.z, a.w || b.w); }
float or(in float a, in float b) { return min(on(a), on(b)); }
vec2  or(in vec2  a, in vec2  b) { return min(on(a), on(b)); }
vec3  or(in vec3  a, in vec3  b) { return min(on(a), on(b)); }
vec4  or(in vec4  a, in vec4  b) { return min(on(a), on(b)); }

#endif

#ifndef XOR
#define XOR

float xor(in bool  a, in bool  b) { return float(a != b); }
vec2  xor(in bvec2 a, in bvec2 b) { return vec2(a.x != b.x, a.y != b.y); }
vec3  xor(in bvec3 a, in bvec3 b) { return vec3(a.x != b.x, a.y != b.y, a.z != b.z); }
vec4  xor(in bvec4 a, in bvec4 b) { return vec4(a.x != b.x, a.y != b.y, a.z != b.z, a.w != b.w); }
float xor(in float a, in float b) { return or(a, b) - and(a, b); }
vec2  xor(in vec2  a, in vec2  b) { return or(a, b) - and(a, b); }
vec3  xor(in vec3  a, in vec3  b) { return or(a, b) - and(a, b); }
vec4  xor(in vec4  a, in vec4  b) { return or(a, b) - and(a, b); }

#endif

#ifndef NAND
#define NAND

float nand(in bool  a, in bool  b) { return 1.0 - and(a, b); }
vec2  nand(in bvec2 a, in bvec2 b) { return 1.0 - and(a, b); }
vec3  nand(in bvec3 a, in bvec3 b) { return 1.0 - and(a, b); }
vec4  nand(in bvec4 a, in bvec4 b) { return 1.0 - and(a, b); }
float nand(in float a, in float b) { return 1.0 - and(a, b) ;}
vec2  nand(in vec2  a, in vec2  b) { return 1.0 - and(a, b) ;}
vec3  nand(in vec3  a, in vec3  b) { return 1.0 - and(a, b) ;}
vec4  nand(in vec4  a, in vec4  b) { return 1.0 - and(a, b) ;}

#endif

#ifndef NOR
#define NOR

float nor(in bool  a, in bool  b) { return 1.0 - or(a, b); }
vec2  nor(in bvec2 a, in bvec2 b) { return 1.0 - or(a, b); }
vec3  nor(in bvec3 a, in bvec3 b) { return 1.0 - or(a, b); }
vec4  nor(in bvec4 a, in bvec4 b) { return 1.0 - or(a, b); }
float nor(in float a, in float b) { return 1.0 - or(a, b) ;}
vec2  nor(in vec2  a, in vec2  b) { return 1.0 - or(a, b) ;}
vec3  nor(in vec3  a, in vec3  b) { return 1.0 - or(a, b) ;}
vec4  nor(in vec4  a, in vec4  b) { return 1.0 - or(a, b) ;}

#endif

#ifndef XNOR
#define XNOR

float xnor(in bool  a, in bool  b) { return 1.0 - xor(a, b); }
vec2  xnor(in bvec2 a, in bvec2 b) { return 1.0 - xor(a, b); }
vec3  xnor(in bvec3 a, in bvec3 b) { return 1.0 - xor(a, b); }
vec4  xnor(in bvec4 a, in bvec4 b) { return 1.0 - xor(a, b); }
float xnor(in float a, in float b) { return 1.0 - xor(a, b) ;}
vec2  xnor(in vec2  a, in vec2  b) { return 1.0 - xor(a, b) ;}
vec3  xnor(in vec3  a, in vec3  b) { return 1.0 - xor(a, b) ;}
vec4  xnor(in vec4  a, in vec4  b) { return 1.0 - xor(a, b) ;}

#endif

#ifndef EVERY
#define EVERY

float every(in bvec2 a) { return float(all(a)); }
float every(in bvec3 a) { return float(all(a)); }
float every(in bvec4 a) { return float(all(a)); }
float every(in float a) { return mmin(on(a)); }
float every(in vec2  a) { return mmin(on(a)); }
float every(in vec3  a) { return mmin(on(a)); }
float every(in vec4  a) { return mmin(on(a)); }

#endif

#ifndef SOME
#define SOME

float some(in bvec2 a) { return float(any(a)); }
float some(in bvec3 a) { return float(any(a)); }
float some(in bvec4 a) { return float(any(a)); }
float some(in vec2  a) { return mmax(on(a)); }
float some(in vec3  a) { return mmax(on(a)); }
float some(in vec4  a) { return mmax(on(a)); }

#endif

#ifndef NEVERY
#define NEVERY

float nevery(in bvec2 a) { return 1.0 - every(a); }
float nevery(in bvec3 a) { return 1.0 - every(a); }
float nevery(in bvec4 a) { return 1.0 - every(a); }
float nevery(in vec2  a) { return 1.0 - every(a); }
float nevery(in vec3  a) { return 1.0 - every(a); }
float nevery(in vec4  a) { return 1.0 - every(a); }

#endif

#ifndef NSOME
#define NSOME

float nsome(in bvec2 a) { return 1.0 - some(a); }
float nsome(in bvec3 a) { return 1.0 - some(a); }
float nsome(in bvec4 a) { return 1.0 - some(a); }
float nsome(in vec2  a) { return 1.0 - some(a); }
float nsome(in vec3  a) { return 1.0 - some(a); }
float nsome(in vec4  a) { return 1.0 - some(a); }

#endif

#endif // LOGICAL

