
// due to linear filtering of the volume texture, samples are non zero at boundaries 
// even if the occupancy is zero, so we need to take a backstep
trace.skip_distance = ray.max_voxel_distance * 2.0; 
trace.skipped_distance -= trace.skip_distance;

// update trace distance and avoid goind outside ray bounds
trace.distance -= trace.skip_distance;
trace.distance = max(trace.distance, ray.start_distance);

// update trace
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// update ray start
ray.start_distance = trace.distance;
ray.span_distance = max(ray.end_distance - ray.start_distance, 0.0);
