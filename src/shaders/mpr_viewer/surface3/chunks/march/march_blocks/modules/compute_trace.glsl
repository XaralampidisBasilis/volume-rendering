
// compute trace from voxel
trace.distance = block.entry_distance;
trace.position = camera.position + ray.direction * trace.distance;

// compute gradient at trace
#include "./compute_gradient_central"