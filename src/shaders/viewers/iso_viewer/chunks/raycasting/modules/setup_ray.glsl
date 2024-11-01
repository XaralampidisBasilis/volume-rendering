
// start ray intersection flag, origin, direction
ray.origin_position = v_camera;
ray.step_direction = normalize(v_direction);
ray.max_voxel_distance = length(volume.spacing);

// volume box 
ray.min_position = vec3(0.0);
ray.max_position = volume.size;

// make ray bounding box a tad smaller to avoid boundary numerical instabilities
ray.min_position += volume.spacing * MILLI_TOL;
ray.max_position -= volume.spacing * MILLI_TOL;

// compute global rays bound distances with the volume box
vec2 ray_bounds = box_bounds(ray.min_position, ray.max_position, ray.origin_position);
ray_bounds = max(ray_bounds, 0.0);
ray_bounds.x = min(ray_bounds.x, ray_bounds.y);
ray.min_distance = ray_bounds.x;
ray.max_distance = ray_bounds.y;

// compute current ray intersection distances with the volume box
vec2 ray_distances = intersect_box(ray.min_position, ray.max_position, ray.origin_position, ray.step_direction);
ray_distances = max(ray_distances, 0.0);
ray_distances.x = min(ray_distances.x, ray_distances.y);

// update current ray bound distances
ray.min_start_distance = ray_distances.x;
ray.max_end_distance = ray_distances.y;
ray.max_span_distance = ray.max_end_distance - ray.min_start_distance;
ray.min_start_position = ray.origin_position + ray.step_direction * ray.min_start_position;
ray.max_end_position = ray.origin_position + ray.step_direction * ray.max_end_distance;

// update ray distances
ray.start_distance = ray.min_start_distance;
ray.end_distance = ray.max_end_distance;
ray.span_distance = ray.max_span_distance;
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
ray.end_position = ray.origin_position + ray.step_direction * ray.end_distance;

// update trace 
trace_prev = trace;
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

