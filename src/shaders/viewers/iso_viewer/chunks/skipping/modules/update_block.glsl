
// compute block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords) * occumap.spacing;
vec3 block_max_position = block_min_position + occumap.spacing;

// make occupancy block a tad bigger to avoid staying in the same block
block_min_position -= occumap.spacing * MILLI_TOL;  
block_max_position += occumap.spacing * MILLI_TOL;  

// intersect ray with block to find the skipping distance
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, ray.step_direction);
trace.skipped_distance += trace.skip_distance;

// update trace
trace.distance += trace.skip_distance;
trace.position += trace.skip_distance * ray.step_direction;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;
