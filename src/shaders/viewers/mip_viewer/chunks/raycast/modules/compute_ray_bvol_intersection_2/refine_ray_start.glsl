
// move to the start of the occupied block
ray.start_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 0.5; // safeguard

// compute start position
ray.start_distance = max(ray.start_distance, box.entry_distance);
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

