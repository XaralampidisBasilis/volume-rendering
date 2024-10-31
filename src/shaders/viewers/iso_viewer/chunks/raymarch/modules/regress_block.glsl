
// compute block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords + 0) - MILLI_TOL;
vec3 block_max_position = vec3(trace.block_coords + 1) + MILLI_TOL;
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// find block intersection distance s
vec2 block_distances = intersect_box(block_min_position, block_max_position, trace.position, ray.step_direction);

// find block resample distance in order to resample the occumap
resample_distance = trace.distance + block_distances.y;

// reverse trace to the start of the block and a bit before
trace.skip_distance = block_distances.x - ray.max_voxel_distance * 2.0;
trace.skipped_distance += trace.skip_distance;

// take a trace backstep 
trace.distance += trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
