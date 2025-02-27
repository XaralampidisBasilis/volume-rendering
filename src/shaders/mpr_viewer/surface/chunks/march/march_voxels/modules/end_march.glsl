
if (voxel.intersected)
{
    // compute trace from voxel
    trace.distance = voxel.entry_distance;
    trace.position = voxel.entry_position;
    trace.uvw = trace.position * u_intensity_map.inv_size;

    // compute gradient at trace
    #include "./modules/compute_gradient"
}

if (voxel.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
