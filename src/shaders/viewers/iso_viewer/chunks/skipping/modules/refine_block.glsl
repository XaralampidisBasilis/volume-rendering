
// due to linear filtering of the volume texture, samples are non zero at boundaries 
// even if the occupancy is zero, so we need to take a backstep
trace.skip_distance = 2.0 * ray.max_voxel_distance; 
trace.skipped_distance -= trace.skip_distance;

// update trace distance and avoid goind outside ray bounds
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);

// update trace positional data
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = int(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// update ray start
ray.start_distance = trace.distance;
ray.span_distance = max(ray.max_distance - ray.start_distance, 0.0);
