
// Compute block min max coords in distance map
block.min_coords = block.coords + 0;
block.max_coords = block.coords + 1;

// Compute block min max position in model space  
block.min_position = vec3(block.min_coords) * u_distmap.spacing;
block.max_position = vec3(block.max_coords) * u_distmap.spacing;

// intersect ray with block to find start distance and position
ray.start_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;

// update ray start position
ray.start_distance = max(ray.start_distance, box.entry_distance);
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

