
// Compute voxel min max positions 
vec3 min_position = floor(trace.position) + 0.0;
vec3 max_position = floor(trace.position) + 1.0;  

// compute voxel ray intersection to correct final position
float correction = intersect_box_min(min_position, max_position, trace.position, ray.direction);
trace.distance += correction;
trace.position += ray.direction * correction;
trace.uvw = u_volume.inv_dimensions * trace.position;

// compute trace gradient
#include "./compute_gradient"
