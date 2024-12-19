
// Update count
block.skip_count++;

// Compute block min max positions in model space  
block.min_position = (vec3(block.coords + 0) - MILLI_TOLERANCE) * u_extremap.spacing;
block.max_position = (vec3(block.coords + 1) + MILLI_TOLERANCE) * u_extremap.spacing;

// intersect ray with block to find trace distance
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.position = camera.position + ray.step_direction * trace.distance;

// update conditions
trace.terminated = trace.distance > ray.end_distance;