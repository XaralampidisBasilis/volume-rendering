
// compute rays bound distances with the volume box
vec2 ray_distance_bounds = box_bounds(ray.box_min_position, ray.box_max_position, ray.camera_position);
ray.min_start_distance = ray_distance_bounds.x;
ray.max_end_distance = ray_distance_bounds.y;
ray.max_span_distance = ray_distance_bounds.y - ray_distance_bounds.x;