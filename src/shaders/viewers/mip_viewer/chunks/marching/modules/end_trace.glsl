
// case trace intersecred
if (trace.intersected) 
{
    #if TRACE_POSITION_REFINEMENT_ENABLED == 1
    #include "./compute_intersection_refinement"
    #endif

    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./compute_gradient_refinement"
    #endif
}

// case trace suspended
if (trace.suspended)
{
    #if TRACE_GRADIENT_REFINEMENT_ENABLED == 1
    #include "./compute_gradient_refinement"
    #endif
}

// case trace terminated
if (trace.terminated)
{
    #include "./discard_trace"
}

// update mean cummulative values
trace.mean_step_scaling /= float(trace.step_count);
trace.mean_step_distance /= float(trace.step_count);
