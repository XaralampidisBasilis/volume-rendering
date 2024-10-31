
// compute occupied block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords) * occumap.spacing;
vec3 block_max_position = block_min_position + occumap.spacing;
vec2 block_distances = intersect_box(block_min_position, block_max_position, trace.position, ray.step_direction);

resample_distance = block_distances.y + trace.distance;

// compute the distance from the start of the block
// due to linear filtering of the volume texture, samples are non zero at boundaries 
// even if the occupancy is zero, so we need to take a backstep equal to the max voxel distance
trace.skip_distance = block_distances.x + ray.max_voxel_distance;
trace.skipped_distance -= trace.skip_distance;

// take a trace backstep 
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
