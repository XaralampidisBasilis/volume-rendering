
// compute the distance to get to the start of the occupied block plus a nudge
ray.start_distance = intersect_box_min(block.min_position, block.max_position, ray.camera_position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;  

// update ray start distance and position
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;

