
#include "./sample_volume"
ray.intersected = trace.sample_error > 0.0 && trace.gradient_magnitude > raymarch.gradient_threshold;
if (ray.intersected) break;

trace_prev = trace;
#include "./update_trace"
if (trace.distance > ray.end_distance) break;