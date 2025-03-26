// Compute min max positions 
voxel.min_position = vec3(voxel.coords + 0);
voxel.max_position = vec3(voxel.coords + 1);  

// compute voxel entry from previous exit, 
voxel.entry_distance = voxel.exit_distance;
voxel.entry_position = voxel.exit_position;

// compute voxel ray intersection to find exit, 
voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, ray.start_position, ray.direction, voxel.axis);
voxel.exit_position = ray.start_position + ray.direction * voxel.exit_distance;

// compute break conditions
voxel.terminated = (voxel.exit_distance > ray.span_distance);
voxel.intersected = (texelFetch(u_textures.binary_map, voxel.coords, 0).r > 0.0);

// compute next voxel coordinates
voxel.coords[voxel.axis] += ray.octant[voxel.axis];

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
