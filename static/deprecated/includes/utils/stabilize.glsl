
float stabilize(in float v, in float tol) { return ssign(v) * max(abs(v), tol); }
vec2  stabilize(in vec2  v, in float tol) { return ssign(v) * max(abs(v), tol); }
vec3  stabilize(in vec3  v, in float tol) { return ssign(v) * max(abs(v), tol); }
vec4  stabilize(in vec4  v, in float tol) { return ssign(v) * max(abs(v), tol); }

float stabilize(in float v) { return ssign(v) * max(abs(v), 1e-6); }
vec2  stabilize(in vec2  v) { return ssign(v) * max(abs(v), 1e-6); }
vec3  stabilize(in vec3  v) { return ssign(v) * max(abs(v), 1e-6); }
vec4  stabilize(in vec4  v) { return ssign(v) * max(abs(v), 1e-6); }
