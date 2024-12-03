
// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_min(block.min_position, block.max_position, ray.camera_position, ray.step_direction);

// update ray end position
ray.end_position = ray.camera_position + ray.step_direction * ray.end_distance; 
