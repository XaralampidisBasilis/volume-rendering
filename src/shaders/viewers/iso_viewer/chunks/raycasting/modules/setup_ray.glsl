
// start ray intersection flag, origin, direction
ray.intersected = false;
ray.origin_position = v_camera;
ray.step_direction = normalize(v_direction);
ray.max_voxel_distance = length(volume.spacing);

// ray bounding box 
ray.min_position = vec3(0.0);
ray.max_position = volume.size;

// make ray bounding box a tad smaller to avoid boundary numerical instabilities
ray.min_position += volume.spacing * MILLI_TOL;
ray.max_position -= volume.spacing * MILLI_TOL;

// compute ray bound distances from the ray bounding box
vec2 ray_bounds = box_bounds(ray.min_position, ray.max_position, ray.origin_position);
ray_bounds = max(ray_bounds, 0.0); 
ray.min_start_distance = ray_bounds.x;
ray.max_end_distance = ray_bounds.y;
ray.max_span_distance = ray.max_end_distance - ray.min_start_distance;
ray.max_span_distance = max(ray.max_span_distance, 0.0);

// compute ray intersection distances with the ray bounding box
vec2 ray_distances = intersect_box(ray.min_position, ray.max_position, ray.origin_position, ray.step_direction, ray.start_position, ray.end_position);
ray_distances = max(ray_distances, 0.0); 
ray.start_distance = ray_distances.x;
ray.end_distance = ray_distances.y;
ray.span_distance = ray.max_distance - ray.min_distance;
ray.span_distance = max(ray.span_distance, 0.0);

// update trace start 
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = int(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;
