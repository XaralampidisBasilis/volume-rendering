
// initialize raymarch
#include "./modules/start_trace_previous"

// raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps; trace.steps++) 
{
    #include "./modules/update_trace_sample"

    ray.intersected = trace.error > 0.0 && trace.gradient_norm > gradient_threshold;
    if (ray.intersected) break;

    prev_trace = trace;
    #include "./modules/update_trace_position"
    if (trace.distance > ray.max_distance) break;
}   

