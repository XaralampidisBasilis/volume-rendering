
// normalize trace abs error 
vec3 debug_trace_value_abs_error = mmix(BLACK_COLOR, RED_COLOR, abs(trace.value_error / CENTI_TOLERANCE));

debug.trace_value_abs_error = vec4(debug_trace_value_abs_error, 1.0);
