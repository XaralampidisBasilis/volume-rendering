float minabs(in float v, in float b) { return ssign(v) * min(abs(v), b); }
vec2  minabs(in vec2  v, in float b) { return ssign(v) * min(abs(v), b); }
vec3  minabs(in vec3  v, in float b) { return ssign(v) * min(abs(v), b); }
vec4  minabs(in vec4  v, in float b) { return ssign(v) * min(abs(v), b); }
vec2  minabs(in vec2  v, in vec2  b) { return ssign(v) * min(abs(v), b); }
vec3  minabs(in vec3  v, in vec3  b) { return ssign(v) * min(abs(v), b); }
vec4  minabs(in vec4  v, in vec4  b) { return ssign(v) * min(abs(v), b); }
