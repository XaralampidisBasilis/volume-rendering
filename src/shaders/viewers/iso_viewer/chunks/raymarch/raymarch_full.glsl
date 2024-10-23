
// initialize raymarch
#include "./modules/initialize_trace"

// raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps; trace.steps++) 
{
    #include "./modules/update_trace_sample"

    ray.intersected = trace.error > 0.0 && length(trace.gradient) > gradient_threshold;
    if (ray.intersected) break;

    prev_trace = trace;
    #include "./modules/update_trace_position"
    if (trace.distance > ray.max_distance) break;
}   

