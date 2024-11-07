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
    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./compute_trace_gradient_refinement"
    #endif
}

if (trace.terminated)
{
    #include "./terminate_trace"

    #if TRACE_DISCARDING_DISABLED == 0
    discard;  
    #endif
}
