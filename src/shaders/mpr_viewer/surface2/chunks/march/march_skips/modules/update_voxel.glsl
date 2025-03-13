
// Compute chebysev distance for empty space skipping
voxel.cheby_distance = texelFetch(u_textures.distance_map, voxel.coords, 0).r;

// Compute min max coordinates 
int radius = max(0, voxel.cheby_distance - 1);
voxel.min_coords = voxel.coords - radius;
voxel.max_coords = voxel.coords + radius;

// Compute min max positions 
voxel.min_position = vec3(voxel.min_coords + 0);
voxel.max_position = vec3(voxel.max_coords + 1);  
voxel.min_position *= u_volume.inv_dimensions;
voxel.max_position *= u_volume.inv_dimensions;

// compute entry from previous exit, 
voxel.entry_distance = voxel.exit_distance;
voxel.entry_position = voxel.exit_position;

// compute voxel ray intersection to find exit, 
voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, camera.position, ray.direction, voxel.axis);
voxel.exit_position = camera.position;
voxel.exit_position += ray.direction * voxel.exit_distance;

// compute break conditions
voxel.intersected = voxel.cheby_distance == 0;
voxel.terminated = voxel.entry_distance > ray.end_distance;

// compute next coordinates 
int coordinate = voxel.coords[voxel.axis];
int offset = ray.sign[voxel.axis] * voxel.cheby_distance;
voxel.coords = ivec3(voxel.exit_position * u_volume.dimensions);
voxel.coords[voxel.axis] = coordinate + offset;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
