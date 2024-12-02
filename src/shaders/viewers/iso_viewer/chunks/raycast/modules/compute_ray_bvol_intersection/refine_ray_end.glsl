
// compute the distance to get to the end of the occupied block plus a nudge
ray.end_distance = intersect_box_max(block.min_position, block.max_position, ray.camera_position, ray.step_direction);
ray.end_distance += u_volume.spacing_length * 2.0;  

// update ray start distance and position
ray.end_distance = min(ray.end_distance, ray.box_end_distance);
ray.end_position = ray.camera_position + ray.step_direction * ray.end_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;
