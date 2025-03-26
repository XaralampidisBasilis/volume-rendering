
// start block at ray start
block.coords = ivec3(ray.start_position); 
block.coords = clamp(block.coords, u_bbox.min_coords, u_bbox.max_coords);

block.exit_distance = 0.0;
block.exit_position = ray.start_position;
