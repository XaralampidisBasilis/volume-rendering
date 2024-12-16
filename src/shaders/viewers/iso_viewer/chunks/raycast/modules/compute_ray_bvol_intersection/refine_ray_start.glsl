
// Compute block min max position in model space  
block.min_position = (vec3(block.coords) + 0) * u_distmap.spacing;
block.max_position = (vec3(block.coords) + 1) * u_distmap.spacing;

// Increase block size by a voxel
block.min_position -= u_volume.spacing;
block.max_position += u_volume.spacing;

// intersect ray with block to find start distance and position
ray.start_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.start_distance = max(ray.start_distance, box.entry_distance);
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

