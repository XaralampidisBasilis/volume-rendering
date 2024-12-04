
// intersect ray with block to find start distance and position
ray.start_distance = intersect_box_max(block.min_position, block.max_position, ray.camera_position, ray.step_direction);

// update ray start position
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 
