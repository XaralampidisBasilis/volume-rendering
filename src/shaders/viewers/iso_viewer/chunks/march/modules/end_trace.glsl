
if (trace.intersected) 
{
    #if TRACE_REFINE_POSITION_ENABLED == 1
    #include "./refine_trace_position"
    #endif
    #if TRACE_REFINE_GRADIENT_ENABLED == 1
    #include "./refine_trace_gradient"
    #endif
}
if (trace.suspended)
{
    #if TRACE_REFINE_GRADIENT_ENABLED == 1
    #include "./refine_trace_gradient"
    #endif
}
if (trace.terminated)
{
    #include "./discard_trace"
}
