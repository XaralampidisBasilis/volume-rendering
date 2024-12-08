
// normalize trace error
vec3 debug_trace_error = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, trace.error / MILLI_TOLERANCE));

debug.trace_error = vec4(debug_trace_error, 1.0);
