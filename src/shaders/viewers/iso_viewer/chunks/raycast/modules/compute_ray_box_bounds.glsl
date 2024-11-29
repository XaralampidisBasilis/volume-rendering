
// compute rays bound distances with the volume box
vec2 ray_box_bounds = box_bounds(ray.box_min_position, ray.box_max_position, ray.camera_position);
ray.box_min_distance = ray_box_bounds.x;
ray.box_max_distance = ray_box_bounds.y;
ray.box_max_span = ray_box_bounds.y - ray_box_bounds.x;