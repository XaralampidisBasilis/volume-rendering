
// compute trace from voxel
trace.position = voxel.entry_position * u_volume.spacing;
trace.distance = dot(trace.position - camera.position, ray.direction);

// compute gradient 
#include "./compute_gradient"