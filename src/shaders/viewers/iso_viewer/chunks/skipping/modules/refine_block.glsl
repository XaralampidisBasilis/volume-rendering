// compute occupied block min and max positions in space
vec3 block_min_position = vec3(trace.block_coords + 0);
vec3 block_max_position = vec3(trace.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// make occupied block bigger by a voxel to include boundary voxels that are
// occupied also due to linear filtering of the volume texture
block_min_position -= volume.spacing;
block_max_position += volume.spacing;

// compute the negative distance to the start of the block
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
// trace.skip_distance += length(volume.spacing);
trace.skipped_distance -= trace.skip_distance;

// take trace backstep 
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.skip_distance * ray.step_direction;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// update previous trace
// if(trace_prev.distance > trace.distance) trace_prev = trace;