
// compute voxel coords
voxel.coords = ivec3(voxel.exit_position * u_intensity_map.inv_spacing);

// Compute chebysev distance for skipping
voxel.cheby_distance = int(texelFetch(u_textures.distance_map, voxel.coords, 0).r * 255.0);

// Compute voxel min max coordinates 
voxel.coords_step = ivec3(max(0, voxel.cheby_distance - 1));
voxel.min_coords = voxel.coords - voxel.coords_step;
voxel.max_coords = voxel.coords + voxel.coords_step;

// Compute voxel min max positions 
voxel.min_position = (vec3(voxel.min_coords + 0) - TOLERANCE.MILLI) * u_intensity_map.spacing;
voxel.max_position = (vec3(voxel.max_coords + 1) + TOLERANCE.MILLI) * u_intensity_map.spacing;  

// compute voxel entry from previous exit, 
voxel.entry_distance = voxel.exit_distance;
voxel.entry_position = voxel.exit_position;

// compute voxel ray intersection to find exit, 
voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, camera.position, ray.direction);
voxel.exit_position = camera.position + ray.direction * voxel.exit_distance;

// compute voxel conditions
voxel.intersected = voxel.cheby_distance == 0;
voxel.terminated = voxel.entry_distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
