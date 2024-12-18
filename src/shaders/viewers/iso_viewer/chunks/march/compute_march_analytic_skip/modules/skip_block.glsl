
// Compute block min max coords in distance map
block.min_coords = block.coords - (block.value - 1);
block.max_coords = block.coords + (block.value - 1);

// Compute block min max position in model space  
// add small tolerance to move to next block
block.min_position = (vec3(block.min_coords + 0) - MILLI_TOLERANCE) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = (vec3(block.max_coords + 1) + MILLI_TOLERANCE) * u_distmap.spacing - u_volume.spacing * 0.5;  

// update position
prev_trace = trace;
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.position = camera.position + ray.step_direction * trace.distance; 
trace.step_distance = trace.distance - prev_trace.distance;

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;

// update count
block.skip_count++;


