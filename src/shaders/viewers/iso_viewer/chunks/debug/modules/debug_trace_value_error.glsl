
// normalize trace error
vec3 debug_trace_value_error = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, trace.value_error / CENTI_TOLERANCE));

debug.trace_value_error = vec4(debug_trace_value_error, 1.0);
