
// Update count
block.skip_count++;

// Compute block coords from ray end position
block.coords = ivec3(ray.end_position * u_extremap.inv_spacing);

// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_extremap.spacing;
block.max_position = vec3(block.coords + 1) * u_extremap.spacing;

// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.end_distance += u_volume.spacing_length * 2.0;

// update ray end position
ray.end_distance = min(ray.end_distance, box.exit_distance);
ray.end_position = camera.position + ray.step_direction * ray.end_distance; 
