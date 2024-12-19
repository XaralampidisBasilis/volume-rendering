
// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction, block.step_coords);

// update ray end position
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 

// Compute block coords step
ivec3 step_coords = ivec3((ray.end_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing) - block.coords;
block.step_coords = block.value * block.step_coords + (1 - abs(block.step_coords)) * step_coords;