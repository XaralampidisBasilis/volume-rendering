#ifndef LOGICAL
#define LOGICAL

#ifndef MMIN
#include "./mmin"
#endif

#ifndef MMAX
#include "./mmax"
#endif

// on
float on(in float a) { return step(0.0, a); }
vec2  on(in vec2  a) { return step(0.0, a); }
vec3  on(in vec3  a) { return step(0.0, a); }
vec4  on(in vec4  a) { return step(0.0, a); }

// off
float off(in float a) { return 1.0 - step(0.0, a); }
vec2  off(in vec2  a) { return 1.0 - step(0.0, a); }
vec3  off(in vec3  a) { return 1.0 - step(0.0, a); }
vec4  off(in vec4  a) { return 1.0 - step(0.0, a); }

// and
float and(in float a, in float b) { return min(step(0.0, a), step(0.0, b)); }
vec2  and(in vec2  a, in vec2  b) { return min(step(0.0, a), step(0.0, b)); }
vec3  and(in vec3  a, in vec3  b) { return min(step(0.0, a), step(0.0, b)); }
vec4  and(in vec4  a, in vec4  b) { return min(step(0.0, a), step(0.0, b)); }
vec2  and(in float a, in vec2  b) { return min(step(0.0, vec2(a)), step(0.0, b)); }
vec3  and(in float a, in vec3  b) { return min(step(0.0, vec3(a)), step(0.0, b)); }
vec4  and(in float a, in vec4  b) { return min(step(0.0, vec4(a)), step(0.0, b)); }
vec2  and(in vec2  a, in float b) { return min(step(0.0, a), step(0.0, vec2(b))); }
vec3  and(in vec3  a, in float b) { return min(step(0.0, a), step(0.0, vec3(b))); }
vec4  and(in vec4  a, in float b) { return min(step(0.0, a), step(0.0, vec4(b))); }

// or
float or(in float a, in float b) { return max(step(0.0, a), step(0.0, b)); }
vec2  or(in vec2  a, in vec2  b) { return max(step(0.0, a), step(0.0, b)); }
vec3  or(in vec3  a, in vec3  b) { return max(step(0.0, a), step(0.0, b)); }
vec4  or(in vec4  a, in vec4  b) { return max(step(0.0, a), step(0.0, b)); }
vec2  or(in float a, in vec2  b) { return max(step(0.0, vec2(a)), step(0.0, b)); }
vec3  or(in float a, in vec3  b) { return max(step(0.0, vec3(a)), step(0.0, b)); }
vec4  or(in float a, in vec4  b) { return max(step(0.0, vec4(a)), step(0.0, b)); }
vec2  or(in vec2  a, in float b) { return max(step(0.0, a), step(0.0, vec2(b))); }
vec3  or(in vec3  a, in float b) { return max(step(0.0, a), step(0.0, vec3(b))); }
vec4  or(in vec4  a, in float b) { return max(step(0.0, a), step(0.0, vec4(b))); }

// xor
float xor(in float a, in float b) { return or(a, b) - and(a, b); }
vec2  xor(in vec2  a, in vec2  b) { return or(a, b) - and(a, b); }
vec3  xor(in vec3  a, in vec3  b) { return or(a, b) - and(a, b); }
vec4  xor(in vec4  a, in vec4  b) { return or(a, b) - and(a, b); }
vec2  xor(in float a, in vec2  b) { return or(a, b) - and(a, b); }
vec3  xor(in float a, in vec3  b) { return or(a, b) - and(a, b); }
vec4  xor(in float a, in vec4  b) { return or(a, b) - and(a, b); }
vec2  xor(in vec2  a, in float b) { return or(a, b) - and(a, b); }
vec3  xor(in vec3  a, in float b) { return or(a, b) - and(a, b); }
vec4  xor(in vec4  a, in float b) { return or(a, b) - and(a, b); }

// nand
float nand(in float a, in float b) { return 1.0 - and(a, b) ;}
vec2  nand(in vec2  a, in vec2  b) { return 1.0 - and(a, b) ;}
vec3  nand(in vec3  a, in vec3  b) { return 1.0 - and(a, b) ;}
vec4  nand(in vec4  a, in vec4  b) { return 1.0 - and(a, b) ;}
vec2  nand(in float a, in vec2  b) { return 1.0 - and(a, b) ;} 
vec3  nand(in float a, in vec3  b) { return 1.0 - and(a, b) ;} 
vec4  nand(in float a, in vec4  b) { return 1.0 - and(a, b) ;} 
vec2  nand(in vec2  a, in float b) { return 1.0 - and(a, b) ;} 
vec3  nand(in vec3  a, in float b) { return 1.0 - and(a, b) ;} 
vec4  nand(in vec4  a, in float b) { return 1.0 - and(a, b) ;} 

// nor
float nor(in float a, in float b) { return 1.0 - or(a, b) ;}
vec2  nor(in vec2  a, in vec2  b) { return 1.0 - or(a, b) ;}
vec3  nor(in vec3  a, in vec3  b) { return 1.0 - or(a, b) ;}
vec4  nor(in vec4  a, in vec4  b) { return 1.0 - or(a, b) ;}
vec2  nor(in float a, in vec2  b) { return 1.0 - or(a, b) ;} 
vec3  nor(in float a, in vec3  b) { return 1.0 - or(a, b) ;} 
vec4  nor(in float a, in vec4  b) { return 1.0 - or(a, b) ;} 
vec2  nor(in vec2  a, in float b) { return 1.0 - or(a, b) ;} 
vec3  nor(in vec3  a, in float b) { return 1.0 - or(a, b) ;} 
vec4  nor(in vec4  a, in float b) { return 1.0 - or(a, b) ;} 

// nxor
float nxor(in float a, in float b) { return 1.0 - xor(a, b) ;}
vec2  nxor(in vec2  a, in vec2  b) { return 1.0 - xor(a, b) ;}
vec3  nxor(in vec3  a, in vec3  b) { return 1.0 - xor(a, b) ;}
vec4  nxor(in vec4  a, in vec4  b) { return 1.0 - xor(a, b) ;}
vec2  nxor(in float a, in vec2  b) { return 1.0 - xor(a, b) ;} 
vec3  nxor(in float a, in vec3  b) { return 1.0 - xor(a, b) ;} 
vec4  nxor(in float a, in vec4  b) { return 1.0 - xor(a, b) ;} 
vec2  nxor(in vec2  a, in float b) { return 1.0 - xor(a, b) ;} 
vec3  nxor(in vec3  a, in float b) { return 1.0 - xor(a, b) ;} 
vec4  nxor(in vec4  a, in float b) { return 1.0 - xor(a, b) ;} 

// every
float every(in float a) { return mmin(step(0.0, a)); }
float every(in vec2  a) { return mmin(step(0.0, a)); }
float every(in vec3  a) { return mmin(step(0.0, a)); }
float every(in vec4  a) { return mmin(step(0.0, a)); }
float every(in float a, in float b) { return every(vec2(a, b)); }
float every(in float a, in float b, in float c) { return every(vec3(a, b, c)); }
float every(in float a, in float b, in float c, in float d) { return every(vec4(a, b, c, d)); }

// some
float some(in float a) { return mmax(step(0.0, a)); }
float some(in vec2  a) { return mmax(step(0.0, a)); }
float some(in vec3  a) { return mmax(step(0.0, a)); }
float some(in vec4  a) { return mmax(step(0.0, a)); }
float some(in float a, in float b) { return some(vec2(a, b)); }
float some(in float a, in float b, in float c) { return some(vec3(a, b, c)); }
float some(in float a, in float b, in float c, in float d) { return some(vec4(a, b, c, d)); }

#endif // LOGICAL

