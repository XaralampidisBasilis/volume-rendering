
if (voxel.intersected)
{
    #include "./compute_trace"
}

if (voxel.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
