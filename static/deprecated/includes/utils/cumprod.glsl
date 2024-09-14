vec2 cumprod(in vec2 v) { v.y *= v.x; return v; }
vec3 cumprod(in vec3 v) { v.y *= v.x; v.z *= v.y; return v; }
vec4 cumprod(in vec4 v) { v.y *= v.x; v.z *= v.y; v.w *= v.z; return v; }

ivec2 cumprod(in ivec2 v) { v.y *= v.x; return v; }
ivec3 cumprod(in ivec3 v) { v.y *= v.x; v.z *= v.y; return v; }
ivec4 cumprod(in ivec4 v) { v.y *= v.x; v.z *= v.y; v.w *= v.z; return v; }
