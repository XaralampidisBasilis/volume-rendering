
if (trace.intersected)
{
    #include "./compute_gradient"
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
