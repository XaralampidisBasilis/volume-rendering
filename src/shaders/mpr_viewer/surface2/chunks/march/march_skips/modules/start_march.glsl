
// start voxel at ray start
voxel.coords = ivec3(voxel.exit_position * u_volume.dimensions); 
voxel.exit_distance = ray.start_distance;
voxel.exit_position = ray.start_position;
voxel.coords_step = ivec3(0); 
voxel.cheby_distance = 0;