
if (voxel.intersected)
{
    #include "./compute_trace"
}

if (trace.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
