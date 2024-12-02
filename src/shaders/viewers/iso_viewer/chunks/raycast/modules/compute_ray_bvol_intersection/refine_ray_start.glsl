
// Compute block coords from ray end position
block.coords = ivec3(ray.start_position * u_distmap.inv_spacing);

// Compute block min max coords in distance map
block.min_coords = block.coords + 0;
block.max_coords = block.coords + 1;

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords) - MILLI_TOLERANCE) * u_distmap.spacing;
block.max_position = (vec3(block.max_coords) + MILLI_TOLERANCE) * u_distmap.spacing;

// compute the distance to get to the start of the occupied block plus a nudge
ray.start_distance = intersect_box_min(block.min_position, block.max_position, ray.camera_position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;  

// update ray start distance and position
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 

