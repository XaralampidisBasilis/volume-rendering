
if (trace.intersected)
{
    // chose between current and previous trace
    trace = (trace.intensity > prev_trace.intensity) ? trace : prev_trace;

    // compute gradient at trace
    #include "./modules/compute_gradient"
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
