

// update trace spatial data
trace.step_distance = block.skipping;
trace.skipped += block.skipping;
trace.distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_texture_coords = trace.position * volume.inv_size;
trace.voxel_coords = floor(trace.position * volume.inv_spacing);
