#ifndef TO_COLOR
#define TO_COLOR

vec4 to_color(float x) { return vec4(vec3(x), 1.0); }
vec4 to_color(vec3  x) { return vec4(vec3(x), 1.0); }
vec4 to_color(bool  x) { return vec4(vec3(x), 1.0); }
vec4 to_color(bvec3 x) { return vec4(vec3(x), 1.0); }
vec4 to_color(float x, float alpha) { return vec4(vec3(x), alpha); }
vec4 to_color(vec3  x, float alpha) { return vec4(vec3(x), alpha); }
vec4 to_color(bool  x, float alpha) { return vec4(vec3(x), alpha); }
vec4 to_color(bvec3 x, float alpha) { return vec4(vec3(x), alpha); }

#endif