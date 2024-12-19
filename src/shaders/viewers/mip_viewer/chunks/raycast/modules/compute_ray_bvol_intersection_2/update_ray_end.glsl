
// intersect ray with block to find ray end distance 
ray.end_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction, block.step_coords);

// update ray end position
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
