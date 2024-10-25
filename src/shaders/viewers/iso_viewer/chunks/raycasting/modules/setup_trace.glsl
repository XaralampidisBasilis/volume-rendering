

trace.distance = ray.start_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = int(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;
trace.spanned_distance = trace.distance - ray.start_distance;