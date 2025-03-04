
// copy previous voxel
prev_voxel = voxel;

// compute voxel coords
voxel.coords += voxel.coords_step;

// compute occupation and intersection
voxel.occupied = texelFetch(u_textures.binary_map, voxel.coords, 0).r > 0.0;
voxel.intersected = voxel.occupied ^^ prev_voxel.occupied;

// compute voxel bounding box in model coordinates
voxel.min_position = vec3(voxel.coords + 0) * u_intensity_map.spacing;
voxel.max_position = vec3(voxel.coords + 1) * u_intensity_map.spacing;

// compute voxel ray intersection to find entry and exit distances, 
voxel.entry_distance = voxel.exit_distance;
voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, camera.position, ray.direction, voxel.coords_step);

// compute voxel entry exit positions
voxel.entry_position = voxel.exit_position;
voxel.exit_position = camera.position + ray.direction * voxel.exit_distance;

// compute termination condition
voxel.terminated = voxel.exit_distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
