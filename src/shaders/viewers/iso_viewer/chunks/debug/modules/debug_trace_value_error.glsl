
// normalize trace error
float debug_trace_value_error = map(-1.0, 1.0, trace.value_error / u_debugger.variable1);
vec3 debug_trace_value_error_color = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, debug_trace_value_error);

// vec2 debug_trace_value_error_colormap_coords = vec2(mix(0.5/256.0, 255.5/256.0, debug_trace_value_error), 67.5/256.0); // bkr colormap
// vec3 debug_trace_value_error_mapped_color = texture(u_textures.colormaps, debug_trace_value_error_colormap_coords).rgb;

debug.trace_value_error = vec4(debug_trace_value_error_color, 1.0);
