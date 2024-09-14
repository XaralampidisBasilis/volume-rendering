#ifndef UTILS_FLIP
#define UTILS_FLIP

// Flip the components of vec and ivec types
vec2 flip(in vec2 v) { return v.yx; }
vec3 flip(in vec3 v) { return v.zyx; }
vec4 flip(in vec4 v) { return v.wzyx; }

ivec2 flip(in ivec2 v) { return v.yx; }
ivec3 flip(in ivec3 v) { return v.zyx; }
ivec4 flip(in ivec4 v) { return v.wzyx; }

#endif // UTILS_FLIP
