
// compute block for setback
float backstep = 2.0;
block.min_position = trace.position - backstep;
block.max_position = trace.position + backstep;  

// compute voxel
voxel.exit_distance = intersect_box_min(block.min_position, block.max_position, ray.start_position, ray.direction);
voxel.exit_position = ray.start_position + ray.direction * voxel.exit_distance;
voxel.coords = ivec3(voxel.exit_position);
