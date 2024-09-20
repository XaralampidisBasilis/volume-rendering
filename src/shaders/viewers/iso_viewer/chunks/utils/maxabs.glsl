    float maxabs(in float v, in float a) { return ssign(v) * max(abs(v), a); }
    vec2  maxabs(in vec2  v, in float a) { return ssign(v) * max(abs(v), a); }
    vec3  maxabs(in vec3  v, in float a) { return ssign(v) * max(abs(v), a); }
    vec4  maxabs(in vec4  v, in float a) { return ssign(v) * max(abs(v), a); }
    vec2  maxabs(in vec2  v, in vec2  a) { return ssign(v) * max(abs(v), a); }
    vec3  maxabs(in vec3  v, in vec3  a) { return ssign(v) * max(abs(v), a); }
    vec4  maxabs(in vec4  v, in vec4  a) { return ssign(v) * max(abs(v), a); }