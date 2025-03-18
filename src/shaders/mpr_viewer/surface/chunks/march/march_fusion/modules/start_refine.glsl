
// Compute min max positions 
block.min_position = trace.position - 5.0;
block.max_position = trace.position + 5.0;  

// compute block ray intersection to setback trace
trace.distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.direction);
trace.position = camera.position + ray.direction * trace.distance;

// compute voxel
voxel.coords = ivec3(trace.position);
voxel.exit_distance = trace.distance;
voxel.exit_position = trace.position;
