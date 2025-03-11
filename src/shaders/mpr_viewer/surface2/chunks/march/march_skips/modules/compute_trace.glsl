
// Compute voxel min max positions 
voxel.min_position = vec3(voxel.coords + 0) * u_intensity_map.inv_dimensions;
voxel.max_position = vec3(voxel.coords + 1) * u_intensity_map.inv_dimensions;  

// compute voxel ray intersection
vec2 voxel_distances = intersect_box(voxel.min_position, voxel.max_position, camera.position, ray.direction);
voxel.entry_distance = voxel_distances.x;
voxel.exit_distance = voxel_distances.y;

// compute voxel entry exit positions 
voxel.entry_position = camera.position + ray.direction * voxel.entry_distance;
voxel.exit_position = camera.position + ray.direction * voxel.exit_distance;

// compute trace from voxel
trace.distance = voxel.entry_distance;
trace.position = camera.position + ray.direction * trace.distance;

// compute gradient at trace
#include "./compute_gradient_central"