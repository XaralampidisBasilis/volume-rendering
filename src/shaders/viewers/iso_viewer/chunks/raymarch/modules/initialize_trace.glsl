
trace.spacing = -ray.min_spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * inv_volume_size;

#include "./update_trace_sample"
prev_trace = trace;

trace.spacing = +ray.min_spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * inv_volume_size;