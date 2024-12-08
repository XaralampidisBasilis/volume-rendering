
vec3 debug_value_abs_error = mmix(BLACK_COLOR, RED_COLOR, abs(trace.error / MILLI_TOLERANCE));

debug.trace_abs_error = vec4(debug_value_abs_error, 1.0);
