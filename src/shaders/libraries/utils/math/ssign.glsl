#ifndef SSIGN
#define SSIGN

float ssign(float v) { return (v >= 0.0) ? 1.0 : -1.0; }
vec2  ssign(vec2  v) { return mix(vec2(-1.0), vec2(1.0), greaterThanEqual(v, vec2(0.0))); }
vec3  ssign(vec3  v) { return mix(vec3(-1.0), vec3(1.0), greaterThanEqual(v, vec3(0.0))); }
vec4  ssign(vec4  v) { return mix(vec4(-1.0), vec4(1.0), greaterThanEqual(v, vec4(0.0))); }

#endif // SSIGN
