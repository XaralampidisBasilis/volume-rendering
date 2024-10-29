
// normalize trace step distance to the range [0, 1]
float debug_trace_step_distance = trace.step_distance / 2.0 * ray.max_voxel_distance;

debug.trace_step_distance = vec4(vec3(debug_trace_step_distance), 1.0);
