
float debug_trace_distance_error = trace.distance - dot(trace.position - ray.origin_position, ray.step_direction);
debug_trace_distance_error = map(-1.0, 1.0, debug_trace_distance_error / MICRO_TOL);

vec2 debug_trace_distance_error_colormap_coords = vec2(mix(0.5 / 256.0, 255.5 / 256.0, debug_trace_distance_error), 67.5 / 256.0); 
vec3 debug_trace_distance_error_mapped_color = texture(u_textures.colormaps, debug_trace_distance_error_colormap_coords).rgb;

debug.trace_distance_error = vec4(debug_trace_distance_error_mapped_color, 1.0);
