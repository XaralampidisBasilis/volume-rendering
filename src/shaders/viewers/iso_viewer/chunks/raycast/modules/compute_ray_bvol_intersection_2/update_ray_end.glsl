
// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction, block.coords_step);

// update ray end position
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 

// Compute block coords step
ivec3 mask = abs(block.coords_step);
ivec3 coords = ivec3((ray.end_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);
ivec3 coords_step = coords - block.coords;
block.coords_step *= block.value;
block.coords_step = coords_step + mask * (block.coords_step - coords_step);