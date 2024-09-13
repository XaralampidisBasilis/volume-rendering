
float inside(in float a, in float b, in float v) { return step(a, v) * step(v, b); }
vec2  inside(in vec2  a, in vec2  b, in vec2  v) { return step(a, v) * step(v, b); }
vec3  inside(in vec3  a, in vec3  b, in vec3  v) { return step(a, v) * step(v, b); }
vec4  inside(in vec4  a, in vec4  b, in vec4  v) { return step(a, v) * step(v, b); }

vec2  inside(in float a, in float b, in vec2  v) { return step(a, v) * (1.0 - step(b, v)); }
vec3  inside(in float a, in float b, in vec3  v) { return step(a, v) * (1.0 - step(b, v)); }
vec4  inside(in float a, in float b, in vec4  v) { return step(a, v) * (1.0 - step(b, v)); }
