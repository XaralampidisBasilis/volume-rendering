
// Intersect ray with block to find start distance and position
ray.start_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);

// Update ray start position
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

// // Compute block coords step
// ivec3 mask = abs(block.coords_step);
// ivec3 coords = ivec3((ray.start_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);
// ivec3 coords_step = coords - block.coords;
// block.coords_step *= block.value;
// block.coords_step = coords_step + mask * (block.coords_step - coords_step);