
vec3 volume_min_position = volume.min_position;
vec3 volume_max_position = volume.max_position;

// make volume bounding box a voxel bigger to account for linear filtering
volume_min_position -= volume.spacing;
volume_max_position += volume.spacing;

// make sure volume bounding box is not bigger than ray bounding box
volume_min_position = max(volume_min_position, ray.min_position);
volume_max_position = min(volume_max_position, ray.max_position);

// save ray start distance for later computations
float ray_start_distance = ray.start_distance;

// compute ray intersection distances with the volume bounding box
vec2 ray_distances_bbox = intersect_box(volume_min_position, volume_max_position, ray.origin_position, ray.step_direction);
ray_distances_bbox = max(ray_distances_bbox, 0.0); 
ray.start_distance = ray_distances_bbox.x;
ray.end_distance = ray_distances_bbox.y;
ray.span_distance = ray.end_distance - ray.start_distance;
ray.span_distance = max(ray.span_distance, 0.0);

// compute start end positions
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
ray.end_position = ray.origin_position + ray.step_direction * ray.end_distance;

// update trace 
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// compute skipped distance
trace.skip_distance = max(ray.start_distance - ray_start_distance, 0.0);
trace.skipped_distance += trace.skip_distance;

