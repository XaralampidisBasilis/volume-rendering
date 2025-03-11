
if (voxel.intersected)
{
    // compute trace from voxel
    trace.distance = voxel.entry_distance;
    trace.position = voxel.entry_position;

    // compute gradient at trace
    #include "./compute_gradient"
}

if (voxel.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
