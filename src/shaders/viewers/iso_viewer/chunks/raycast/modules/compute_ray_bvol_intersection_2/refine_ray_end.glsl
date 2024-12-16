
// Compute block min max position in model space  
block.min_position = (vec3(block.coords) - 0.5) * u_distmap.spacing;
block.max_position = (vec3(block.coords) + 0.5) * u_distmap.spacing;

// Increase block boundary by a voxel
block.min_position -= u_volume.spacing * 0.5;
block.max_position += u_volume.spacing * 0.5;

// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.end_distance = min(ray.end_distance, box.exit_distance);
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
