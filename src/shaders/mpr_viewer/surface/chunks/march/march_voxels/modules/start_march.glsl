
// start voxel at ray start
voxel.coords = ivec3(ray.start_distance * u_intensity_map.inv_spacing);
voxel.coords_step = ivec3(0);
voxel.exit_distance = ray.start_distance;
voxel.exit_position = ray.start_position;
