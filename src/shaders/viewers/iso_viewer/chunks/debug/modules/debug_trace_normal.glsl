
// normalize trace normal to the range [0, 1]
vec3 debug_trace_normal = 0.5 - normalize(voxel.gradient) * 0.5 ;

debug.trace_normal = vec4(debug_trace_normal, 1.0);
