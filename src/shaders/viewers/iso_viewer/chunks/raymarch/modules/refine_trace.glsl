trace.step_distance = - ray.step_distance;
trace.distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_texture_coords = trace.position * volume_inv_size;
trace.depth = trace.distance - ray.start_distance;
trace.voxel_coords = floor(trace.position * volume_inv_spacing);
