
// start block at ray start
block.coords = ivec3(ray.start_position * u_volume.dimensions); 
block.exit_distance = ray.start_distance;
block.exit_position = ray.start_position;
