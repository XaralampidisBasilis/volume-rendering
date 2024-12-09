
if (trace.intersected) 
{
    #if REFINE_INTERSECTION_ENABLED == 1
    #include "./refine_intersection"
    #endif
    #if REFINE_GRADIENTS_ENABLED == 1
    #include "./refine_gradients"
    #endif
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #else
    discard_trace(trace);
    discard_voxel(voxel);
    #endif
}

if (trace.exhausted)
{
    // nothing
}
