
// compute trace from voxel
trace.position = voxel.entry_position;
trace.distance = voxel.entry_distance;
trace.uvw = trace.position * u_volume.inv_dimensions;

// compute gradient 
#include "./compute_gradient"