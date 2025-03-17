
// start voxel at ray start
voxel.coords = ivec3(ray.start_position);
voxel.coords = clamp(voxel.coords, u_bbox.min_coords, u_bbox.max_coords);
voxel.exit_distance = ray.start_distance;
voxel.exit_position = ray.start_position;
