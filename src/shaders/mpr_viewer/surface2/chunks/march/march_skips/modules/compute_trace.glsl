
// compute trace from voxel
trace.distance = voxel.entry_distance;
trace.position = camera.position + ray.direction * trace.distance;

// compute gradient at trace
#include "./compute_gradient_central"