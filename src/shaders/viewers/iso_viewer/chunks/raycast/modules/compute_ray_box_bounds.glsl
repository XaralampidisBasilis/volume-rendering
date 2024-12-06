
// compute rays bound distances with the volume box
vec2 ray_box_bounds = box_bounds(box.min_position, box.max_position, camera.position);

box.min_entry_distance = ray_box_bounds.x;
box.max_exit_distance  = ray_box_bounds.y;
box.max_span_distance  = ray_box_bounds.y - ray_box_bounds.x;