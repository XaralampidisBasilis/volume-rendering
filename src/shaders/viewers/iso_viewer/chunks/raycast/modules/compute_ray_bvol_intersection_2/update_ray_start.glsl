
// Intersect ray with block to find start distance and position
ray.start_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction, block.step_coords);

// Update ray start position
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

// // // Compute block coords step
// ivec3 mask = abs(block.step_coords);
// ivec3 coords = ivec3((ray.start_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);
// ivec3 step_coords = coords - block.coords;
// block.step_coords *= block.value;
// block.step_coords = step_coords + mask * (block.step_coords - step_coords);