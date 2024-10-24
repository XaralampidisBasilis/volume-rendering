
trace.spacing = -ray.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * volume_inv_size;

#include "./update_trace_sample"
prev_trace = trace;

trace.spacing = +ray.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * volume_inv_size;