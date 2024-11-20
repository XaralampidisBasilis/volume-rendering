
// current block in model space
vec3 block_min_position = vec3(trace.block_coords + 0) - MILLI_TOLERANCE;
vec3 block_max_position = vec3(trace.block_coords + 1) + MILLI_TOLERANCE;
block_min_position *= u_extremap.spacing;
block_max_position *= u_extremap.spacing;

// compute distance to exit the current block
trace.distance = intersect_box_max(block_min_position, block_max_position, ray.camera_position, ray.step_direction);

