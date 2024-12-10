// volume box 
box.min_position = vec3(0.0);
box.max_position = u_volume.size;

// shrink volume box by a small amount to avoid numerical instabilities in the boundary
box.min_position += u_volume.spacing * MILLI_TOLERANCE;
box.max_position -= u_volume.spacing * MILLI_TOLERANCE;

// compute rays bound distances with the volume box
vec2 ray_box_bounds = box_bounds(box.min_position, box.max_position, camera.position);

box.min_entry_distance = ray_box_bounds.x;
box.max_exit_distance  = ray_box_bounds.y;
box.max_span_distance  = ray_box_bounds.y - ray_box_bounds.x;