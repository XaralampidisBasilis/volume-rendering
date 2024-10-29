
// initialize raymarch
#include "./modules/start_trace_previous"

float gradient_threshold = raymarch.gradient_threshold * volume.max_gradient_magnitude;

// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count; trace.step_count++) 
{
    #include "./modules/sample_volume"

    ray.intersected = trace.sample_error > 0.0 && trace.gradient_magnitude > gradient_threshold;
    if (ray.intersected) break;

    trace_prev = trace;
    #include "./modules/update_trace"
    if (trace.distance > ray.max_distance) break;
}   

