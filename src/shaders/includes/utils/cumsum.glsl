vec2 cumsum(in vec2 v) { v.y += v.x; return v; }
vec3 cumsum(in vec3 v) { v.y += v.x; v.z += v.y; return v; }
vec4 cumsum(in vec4 v) { v.y += v.x; v.z += v.y; v.w += v.z; return v; }

ivec2 cumsum(in ivec2 v) { v.y += v.x; return v; }
ivec3 cumsum(in ivec3 v) { v.y += v.x; v.z += v.y; return v; }
ivec4 cumsum(in ivec4 v) { v.y += v.x; v.z += v.y; v.w += v.z; return v; }
