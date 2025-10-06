

// compute skip distances
ivec3 min_distances, max_distances;
sample_distance_extended_isotropic(block.coords, min_distances, max_distances, block.occupied);
block.skip_coords = mmix(min_distances, max_distances, clamp(ray.signs, 0, 1));
block.skip_coords = max(block.skip_coords , 1);

// compute min/max coords
block.min_coords = block.coords - (block.skip_coords - 1);
block.max_coords = block.coords + (block.skip_coords - 1);

// compute min/max positions
block.min_position = vec3((block.min_coords + 0) * u_volume.block_size) - 0.5;
block.max_position = vec3((block.max_coords + 1) * u_volume.block_size) - 0.5;   

// inflate to avoid boundaries
block.min_position -= 0.001;
block.max_position += 0.001; 

// compute entry from previous exit
block.entry_distance = block.exit_distance;
block.entry_position = block.exit_position;

// compute exit from cell ray intersection 
block.exit_distance = intersect_box_exit(block.min_position, block.max_position, camera.position, ray.inv_direction, block.exit_normal);
block.exit_position = camera.position + ray.direction * block.exit_distance;

// compute span distance
block.span_distance = block.exit_distance - block.entry_distance;

// compute next coordinates
ivec3 next_coords = block.coords + block.skip_coords * ray.signs;
ivec3 exit_coords = ivec3(round(block.exit_position)) / u_volume.block_size;
block.coords = mmix(exit_coords, next_coords, block.exit_normal);

// compute termination condition
block.terminated = block.exit_distance > ray.end_distance;

// update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
stats.num_blocks += 1;
#endif



