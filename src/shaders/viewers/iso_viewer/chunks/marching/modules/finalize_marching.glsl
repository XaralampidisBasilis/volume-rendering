#include "./compute_trace_states"

if (trace.intersected) 
{
    #if TRACE_POSITION_REFINEMENT_ENABLED == 1
    #include "./compute_trace_position_refinement"
    #endif

    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./compute_trace_gradient_refinement"
    #endif
}

if (trace.suspended)
{
    #if TRACE_DISCARDING_DISABLED == 0
    discard;  
    #endif
}

if (trace.terminated)
{
    #include "./terminate_trace_position"

    #if TRACE_DISCARDING_DISABLED == 0
    discard;  
    #endif
}

// update mean cummulative values
trace.mean_step_scaling /= float(trace.step_count);
trace.mean_step_distance /= float(trace.step_count);
