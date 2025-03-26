
// compute coords at ray start
voxel.coords = ivec3(ray.start_position);
voxel.coords = clamp(voxel.coords, u_bbox.min_coords, u_bbox.max_coords);

// compute exit distance, position at ray start
voxel.exit_distance = 0.0;
voxel.exit_position = ray.start_position;
