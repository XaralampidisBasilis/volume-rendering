
// Compute chebysev distance for empty space skipping
block.cheby_distance = texelFetch(u_textures.distance_map, block.coords, 0).r;

// Compute min max coordinates 
int radius = max(0, block.cheby_distance - 1);
block.min_coords = block.coords - radius;
block.max_coords = block.coords + radius;

// Compute min max positions 
block.min_position = vec3(block.min_coords + 0);
block.max_position = vec3(block.max_coords + 1);  

// compute entry from previous exit, 
block.entry_distance = block.exit_distance;
block.entry_position = block.exit_position;

// compute block ray intersection to find exit, 
float penetration = intersect_box_max(block.min_position, block.max_position, ray.start_position, ray.direction, block.axis);
block.exit_distance = ray.start_distance; + penetration;
block.exit_position = ray.start_position; + penetration * ray.direction;

// compute break conditions
block.terminated = (block.entry_distance > ray.end_distance);
block.intersected = (block.cheby_distance == 0);

// compute next coordinates 
int coordinate = block.coords[block.axis];
coordinate += block.cheby_distance * ray.sign[block.axis];

block.coords = ivec3(block.exit_position);
block.coords[block.axis] = coordinate;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
