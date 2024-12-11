
// Update count
block.skip_count++;

// Compute block coords from ray start position
block.coords = ivec3(ray.start_position * u_extremap.inv_spacing);

// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_extremap.spacing;
block.max_position = vec3(block.coords + 1) * u_extremap.spacing;

// intersect ray with block to find start distance and position
ray.start_distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;

// update ray start position
ray.start_distance = max(ray.start_distance, box.entry_distance);
ray.start_position = camera.position + ray.step_direction * ray.start_distance; 

