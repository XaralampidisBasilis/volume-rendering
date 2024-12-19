
// intersect ray with block to find ray start distance 
ray.start_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction, block.step_coords);

// update ray start position
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 
