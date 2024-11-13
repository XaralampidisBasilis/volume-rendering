// compute step stretching  
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_stretching"
#endif

// compute step sclaling 
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update step distance
trace.step_distance = ray.step_distance * trace.step_scaling;
trace.mean_step_scaling += trace.step_scaling;
trace.mean_step_distance += trace.step_distance;
