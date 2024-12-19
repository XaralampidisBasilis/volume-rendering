
// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_distmap.spacing - u_volume.spacing * 0.5;  

// move to the end of the occupied block
ray.end_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.end_distance += u_volume.spacing_length * u_debugging.variable2; // safeguard

// compute end position
ray.end_distance = min(ray.end_distance, box.exit_distance);
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
