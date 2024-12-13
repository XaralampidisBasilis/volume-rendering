
// Compute block min max coords in distance map
block.min_coords = block.coords + 0;
block.max_coords = block.coords + 1;

// Compute block min max position in model space  
block.min_position = vec3(block.min_coords) * u_distmap.spacing;
block.max_position = vec3(block.max_coords) * u_distmap.spacing;

// Increase block size by a voxel
block.min_position -= u_volume.spacing;
block.max_position += u_volume.spacing;

// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
// ray.end_distance += u_volume.spacing_length * 2.0;

// update ray end position
ray.end_distance = min(ray.end_distance, box.exit_distance);
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
