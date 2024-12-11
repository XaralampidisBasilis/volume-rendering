
// update count
block.skip_count++;

// Compute block min max coords in distance map
block.min_coords = block.coords - block.value + 1;
block.max_coords = block.coords + block.value + 0;

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords) - MILLI_TOLERANCE) * u_extremap.spacing;
block.max_position = (vec3(block.max_coords) + MILLI_TOLERANCE) * u_extremap.spacing;

// update position
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.position = camera.position + ray.step_direction * trace.distance; 

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;

// update cumulatives
// trace.skipped_distance += trace.distance - prev_trace.distance;
