
if (trace.intersected)
{
    // #include "./end_trace"
    #include "./compute_gradient"
}
else
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
