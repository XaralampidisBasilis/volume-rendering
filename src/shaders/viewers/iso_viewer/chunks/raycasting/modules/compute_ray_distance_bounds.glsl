// volume box 
ray.min_position = vec3(0.0);
ray.max_position = u_volume.size;

// shrink volume box by a small amount to avoid numerical instabilities in the boundary
ray.min_position += u_volume.spacing * MILLI_TOLERANCE;
ray.max_position -= u_volume.spacing * MILLI_TOLERANCE;

// compute rays bound distances with the volume box
vec2 ray_distance_bounds = box_bounds(ray.min_position, ray.max_position, ray.camera_position);
ray.min_start_distance = ray_distance_bounds.x;
ray.max_end_distance = ray_distance_bounds.y;
ray.max_span_distance = ray_distance_bounds.y - ray_distance_bounds.x;