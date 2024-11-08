
// compute block min and max positions in space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// reverse trace to the start of the block and a bit before
trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
trace.skip_distance += length(u_volume.spacing) * 2.0;

// take a trace backstep 
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
