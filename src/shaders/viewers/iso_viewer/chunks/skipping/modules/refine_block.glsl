
trace.block_coords = ivec3(trace.position / occumap.spacing);

// compute occupied block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords) * occumap.spacing;
vec3 block_max_position = block_min_position + occumap.spacing;

// take backstep to get in the start of the occupied block
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);

// due to linear filtering of the volume texture, samples are non zero at boundaries 
// even if the occupancy is zero, so we need to take a backstep
trace.skip_distance += ray.max_voxel_distance; 
trace.skipped_distance -= trace.skip_distance;

// update trace distance and avoid goind outside ray bounds
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);

// update trace
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// update ray
ray.start_distance = trace.distance;
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
ray.span_distance = max(ray.end_distance - ray.start_distance, 0.0);
