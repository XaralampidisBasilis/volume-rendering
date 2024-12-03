
if (trace.intersected) 
{
    #if TRACE_POSITION_REFINEMENT_ENABLED == 1
    #include "./refine_trace_position"
    #endif
    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./refine_trace_gradient"
    #endif
}
if (trace.suspended)
{
    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./refine_trace_gradient"
    #endif
}
if (trace.terminated)
{
    #include "./discard_trace"
}
