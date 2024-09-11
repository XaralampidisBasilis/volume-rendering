#ifndef UTILS_DIFF
#define UTILS_DIFF

// vec and ivec difference using swizzle for compactness and efficiency
float diff(in vec2  v) { return v.y   - v.x;   }
vec2  diff(in vec3  v) { return v.yz  - v.xy;  }
vec3  diff(in vec4  v) { return v.yzw - v.xyz; }
int   diff(in ivec2 v) { return v.y   - v.x;   }
ivec2 diff(in ivec3 v) { return v.yz  - v.xy;  }
ivec3 diff(in ivec4 v) { return v.yzw - v.xyz; }

#endif // UTILS_DIFF

