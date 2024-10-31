

// setup trace 
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
trace.step_distance = ray.min_step_distance;
trace.step_scaling = 1.0;