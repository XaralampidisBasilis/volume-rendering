
// compute block min and max positions in space
vec3 block_min_position = vec3(occumap.block_coords + 0) - MILLI_TOLERANCE;
vec3 block_max_position = vec3(occumap.block_coords + 1) + MILLI_TOLERANCE;
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// find block skip distance in order to exit the block
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, ray.step_direction);
trace.skip_distance = max(trace.skip_distance, ray.min_step_distance);
trace.skipped_distance += trace.skip_distance;
trace.skip_count++;

// update trace
trace.distance += trace.skip_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
