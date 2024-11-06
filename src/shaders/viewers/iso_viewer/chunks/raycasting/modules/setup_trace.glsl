
// set trace start
trace.distance = ray.start_distance;
trace.position = ray.start_position;

// compute volume texture coordinates
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
    
// set cummulative distances
trace.stepped_distance = 0.0;
trace.spanned_distance = 0.0;
trace.skipped_distance = 0.0;

// set counters
trace.step_count = 0;
trace.skip_count = 0;

// set states
trace.terminated = false;
trace.suspended = false;
trace.intersected = false;