/* the internet **really** likes this one, still no source to be
* found, probably Rey 1998, cited by TestU01 but nothing
* downloadable */  

#ifndef RAND
#define RAND
 
float rand(vec2 v) { return fract(sin(dot(v, vec2(12.9898, 78.233)) + 1.0) * 43758.5453); }

#endif // RAND