
// compute trace luminance
const vec3 luminance = vec3(0.2126, 0.7152, 0.0722);
float trace_luminance = dot(trace.shading, luminance);

debug.trace_luminance = vec4(vec3(trace_luminance), 1.0);
