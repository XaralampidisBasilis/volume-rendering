
// start voxel at ray start
voxel.coords = ivec3(ray.start_position * u_volume.dimensions); 
voxel.exit_distance = ray.start_distance;
voxel.exit_position = ray.start_position;
