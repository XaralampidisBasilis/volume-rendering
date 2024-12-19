
if (trace.intersected) 
{
    #include "./compute_intersection"
    #if REFINE_INTERSECTION_ENABLED == 1
    #include "./refine_intersection"
    #endif
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
    #else
    // discard_trace(trace);
    // discard_voxel(voxel);
    #endif
}

