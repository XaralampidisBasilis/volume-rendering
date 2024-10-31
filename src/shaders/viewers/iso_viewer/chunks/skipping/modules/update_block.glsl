
// compute block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords + 0) - MILLI_TOL;
vec3 block_max_position = vec3(trace.block_coords + 1) + MILLI_TOL;
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// intersect ray with block to find the skipping distance
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, ray.step_direction);
trace.skipped_distance += trace.skip_distance;

// update trace
trace.distance += trace.skip_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.skip_distance * ray.step_direction;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
if (trace.distance > ray.end_distance) break;
