
// start block
block.exit_distance = ray.start_distance;
block.exit_position = camera.position + ray.direction * block.exit_distance; 

block.entry_distance = block.exit_distance;
block.entry_position = block.exit_position; 

block.coords = ivec3(round(block.exit_position)) / u_volume.block_size;
