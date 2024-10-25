
// start ray intersection flag, origin, direction
ray.intersected = false;
ray.origin_position = v_camera;
ray.step_direction = normalize(v_direction);

// compute ray intersection distances with the volume bounding box
vec2 ray_distances = intersect_box(volume.min_position, volume.max_position, ray.origin_position, ray.step_direction);
ray_distances = max(ray_distances, 0.0); 
ray.start_distance = ray_distances.x;
ray.end_distance = ray_distances.y;
ray.span_distance = ray.max_distance - ray.min_distance;
ray.span_distance = max(ray.span_distance, 0.0);

// compute ray intersection positions with the volume bounding box
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
ray.start_position = ray.origin_position + ray.step_direction * ray.end_distance;

// compute the max number of skips based on the currect occupam
ray.max_skip_count = mmax(occumap.dimensions);
ray.max_skip_count = min(ray.max_skip_count, raymarch.max_step_count);

// compute ray bound distances from the volume bounding box
vec2 ray_bounds = sdf_box_bounds(volume.min_position, volume.max_position, ray.origin_position);
ray_bounds = max(ray_bounds, 0.0); 
ray.min_start_distance = ray_bounds.x;
ray.max_end_distance = ray_bounds.y;
ray.max_span_distance = ray.max_end_distance - ray.min_start_distance;
ray.max_span_distance = max(ray.max_span_distance, 0.0);


