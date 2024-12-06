
if (trace.intersected) 
{
    #if TRACE_REFINE_POSITION_ENABLED == 1
    #include "./refine_intersection"
    #endif
    #if TRACE_REFINE_GRADIENT_ENABLED == 1
    #include "./refine_normals"
    #endif
}

if (trace.terminated)
{
    #if FRAGMENT_DISCARDING_DISABLED == 0
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
