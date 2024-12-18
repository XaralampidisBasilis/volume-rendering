
// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_distmap.spacing - u_volume.spacing * 0.5;  

// move to the start of the occupied block
ray.start_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 0.5; // safeguard for numerical instabilities

// compute start position
ray.start_distance = max(ray.start_distance, box.entry_distance);
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

