
// compute occupied block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords) * occumap.spacing;
vec3 block_max_position = block_min_position + occumap.spacing;

// make occupied block bigger by a voxel to include boundary voxels that are
// // occupied also due to linear filtering of the volume texture
block_min_position -= volume.spacing;
block_max_position += volume.spacing;

// compute the distance from the start of the block
trace.skip_distance = intersect_box_min(block_min_position, block_max_position, trace.position, ray.step_direction);
trace.skipped_distance += trace.skip_distance;

// update trace
trace.distance += trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.skip_distance * ray.step_direction;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// update ray
ray.start_distance = trace.distance;
ray.start_position = trace.position;
ray.span_distance = max(ray.end_distance - ray.start_distance, 0.0);
