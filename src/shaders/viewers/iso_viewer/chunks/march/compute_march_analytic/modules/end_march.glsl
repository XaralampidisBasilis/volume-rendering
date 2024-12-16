
if (trace.intersected) 
{
    #include "./compute_gradients"
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #else
    // discard_trace(trace);
    // discard_voxel(voxel);
    #endif
}

if (trace.exhausted)
{
    // nothing
}
