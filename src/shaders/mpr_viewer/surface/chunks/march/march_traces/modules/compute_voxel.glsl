
// compute coords
voxel.coords = ivec3(trace.position);

// compute min max positions 
voxel.min_position = vec3(voxel.coords + 0);
voxel.max_position = vec3(voxel.coords + 1);  

// compute voxel ray intersection to find exit, 
float penetration = intersect_box_min(voxel.min_position, voxel.max_position, ray.start_position, ray.direction);

// compute entry distance position
voxel.entry_distance = ray.start_distance + penetration;
voxel.entry_position = ray.start_position + penetration * ray.direction;

// compute trace 
trace.distance = voxel.entry_distance;
trace.position = voxel.entry_position;
trace.uvw = trace.position * u_volume.inv_dimensions;

// compute trace gradient
#include "./compute_gradient"
