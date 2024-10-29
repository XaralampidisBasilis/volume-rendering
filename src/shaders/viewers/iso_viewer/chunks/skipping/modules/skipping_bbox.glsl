
// make volume bounding box a tad bigger to avoid boundary numerical instabilities
vec3 volume_min_position = volume.min_position - volume.spacing * MILLI_TOL;
vec3 volume_max_position = volume.max_position + volume.spacing * MILLI_TOL;

// make sure volume bounding box is not bigger than ray bounding box
volume_min_position = max(volume_min_position, ray.min_position);
volume_max_position = min(volume_max_position, ray.max_position);

// compute ray intersection distances with the volume bounding box
vec2 ray_distances = intersect_box(volume_min_position, volume_max_position, ray.origin_position, ray.step_direction, ray.start_position, ray.end_position);
ray_distances = max(ray_distances, 0.0); 
ray.start_distance = ray_distances.x;
ray.end_distance = ray_distances.y;
ray.span_distance = ray.max_distance - ray.min_distance;
ray.span_distance = max(ray.span_distance, 0.0);

// update trace 
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = int(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;
trace.skipped_distance = ray.start_distance - ray.min_start_distance;
trace.skipped_distance = max(trace.skipped_distance, 0.0);
