
// Compute voxel coords
voxel.coords = ivec3(trace.position);

// Compute voxel min max positions 
voxel.min_position = vec3(voxel.coords + 0);
voxel.max_position = vec3(voxel.coords + 1);  

// compute voxel ray intersection 
float backstep = intersect_box_min(voxel.min_position, voxel.max_position, trace.position, ray.direction);

// Compute final position
trace.distance += backstep;
trace.position += ray.direction * backstep;

// compute trace gradient
trace.uvw = u_volume.inv_dimensions * trace.position;
#include "./compute_gradient"
