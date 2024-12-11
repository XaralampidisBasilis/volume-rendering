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

// on
float on(in float a) { return step(MICRO_TOLERANCE, abs(a)); }
vec2  on(in vec2  a) { return step(MICRO_TOLERANCE, abs(a)); }
vec3  on(in vec3  a) { return step(MICRO_TOLERANCE, abs(a)); }
vec4  on(in vec4  a) { return step(MICRO_TOLERANCE, abs(a)); }

// off
float off(in float a) { return 1.0 - on(a); }
vec2  off(in vec2  a) { return 1.0 - on(a); }
vec3  off(in vec3  a) { return 1.0 - on(a); }
vec4  off(in vec4  a) { return 1.0 - on(a); }

// and
float and(in float a, in float b) { return min(on(a), on(b)); }
vec2  and(in vec2  a, in vec2  b) { return min(on(a), on(b)); }
vec3  and(in vec3  a, in vec3  b) { return min(on(a), on(b)); }
vec4  and(in vec4  a, in vec4  b) { return min(on(a), on(b)); }


// or
float or(in float a, in float b) { return max(on(a), on(b)); }
vec2  or(in vec2  a, in vec2  b) { return max(on(a), on(b)); }
vec3  or(in vec3  a, in vec3  b) { return max(on(a), on(b)); }
vec4  or(in vec4  a, in vec4  b) { return max(on(a), on(b)); }

// xor
float xor(in float a, in float b) { return or(a, b) - and(a, b); }
vec2  xor(in vec2  a, in vec2  b) { return or(a, b) - and(a, b); }
vec3  xor(in vec3  a, in vec3  b) { return or(a, b) - and(a, b); }
vec4  xor(in vec4  a, in vec4  b) { return or(a, b) - and(a, b); }

// nand
float nand(in float a, in float b) { return 1.0 - and(a, b) ;}
vec2  nand(in vec2  a, in vec2  b) { return 1.0 - and(a, b) ;}
vec3  nand(in vec3  a, in vec3  b) { return 1.0 - and(a, b) ;}
vec4  nand(in vec4  a, in vec4  b) { return 1.0 - and(a, b) ;}

// nor
float nor(in float a, in float b) { return 1.0 - or(a, b) ;}
vec2  nor(in vec2  a, in vec2  b) { return 1.0 - or(a, b) ;}
vec3  nor(in vec3  a, in vec3  b) { return 1.0 - or(a, b) ;}
vec4  nor(in vec4  a, in vec4  b) { return 1.0 - or(a, b) ;}

// nxor
float xnor(in float a, in float b) { return 1.0 - xor(a, b) ;}
vec2  xnor(in vec2  a, in vec2  b) { return 1.0 - xor(a, b) ;}
vec3  xnor(in vec3  a, in vec3  b) { return 1.0 - xor(a, b) ;}
vec4  xnor(in vec4  a, in vec4  b) { return 1.0 - xor(a, b) ;}

// every
float every(in float a) { return mmin(on(a)); }
float every(in vec2  a) { return mmin(on(a)); }
float every(in vec3  a) { return mmin(on(a)); }
float every(in vec4  a) { return mmin(on(a)); }
float every(in float a, in float b) { return every(vec2(a, b)); }
float every(in float a, in float b, in float c) { return every(vec3(a, b, c)); }
float every(in float a, in float b, in float c, in float d) { return every(vec4(a, b, c, d)); }

// some
float some(in float a) { return mmax(on(a)); }
float some(in vec2  a) { return mmax(on(a)); }
float some(in vec3  a) { return mmax(on(a)); }
float some(in vec4  a) { return mmax(on(a)); }
float some(in float a, in float b) { return some(vec2(a, b)); }
float some(in float a, in float b, in float c) { return some(vec3(a, b, c)); }
float some(in float a, in float b, in float c, in float d) { return some(vec4(a, b, c, d)); }

// nevery
float nevery(in float a) { return 1.0 - every(a); }
float nevery(in vec2  a) { return 1.0 - every(a); }
float nevery(in vec3  a) { return 1.0 - every(a); }
float nevery(in vec4  a) { return 1.0 - every(a); }
float nevery(in float a, in float b) { return 1.0 - every(a, b); }
float nevery(in float a, in float b, in float c) { return 1.0 - every(a, b, c); }
float nevery(in float a, in float b, in float c, in float d) { return 1.0 - every(a, b, c, d); }

// nsome
float nsome(in float a) { return 1.0 - some(a); }
float nsome(in vec2  a) { return 1.0 - some(a); }
float nsome(in vec3  a) { return 1.0 - some(a); }
float nsome(in vec4  a) { return 1.0 - some(a); }
float nsome(in float a, in float b) { return 1.0 - some(a, b); }
float nsome(in float a, in float b, in float c) { return 1.0 - some(a, b, c); }
float nsome(in float a, in float b, in float c, in float d) { return 1.0 - some(a, b, c, d); }

#endif // LOGICAL
