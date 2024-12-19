
// move to the end of the occupied block
ray.end_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.end_distance += u_volume.spacing_length * 0.5; // safeguard

// compute end position
ray.end_distance = min(ray.end_distance, box.exit_distance);
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
