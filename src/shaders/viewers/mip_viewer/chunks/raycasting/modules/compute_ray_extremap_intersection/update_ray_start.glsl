
// current block in model space
vec3 block_min_position = vec3(trace.block_coords + 0) * u_extremap.spacing;
vec3 block_max_position = vec3(trace.block_coords + 1) * u_extremap.spacing;

// intersect ray with current block to find entry point
ray.start_distance = intersect_box_min(block_min_position, block_max_position, ray.camera_position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;  

// update start position
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;