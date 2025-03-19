
if (trace.intersected)
{
    #include "./compute_voxel"
}
else
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
