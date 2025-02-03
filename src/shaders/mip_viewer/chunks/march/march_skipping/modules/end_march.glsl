
if (trace.intersected) 
{
    #include "./compute_intersection"
    #include "./compute_gradients"
}

if (trace.exhausted)
{
    // nothing
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}

