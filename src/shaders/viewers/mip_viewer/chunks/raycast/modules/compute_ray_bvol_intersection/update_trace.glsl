
// intersect ray with block to find trace distance
trace.distance = intersect_box_max(block.min_position, block.max_position, camera.position, ray.step_direction);

// update trace position
trace.position = camera.position + ray.step_direction * trace.distance;
