
// update previous
prev_trace = trace;
prev_voxel = voxel;

// update trace
trace.distance = cell.bounds.y;
trace.position = camera.position + ray.step_direction * trace.distance; 

// update voxel
voxel.value = cell.values.y;
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.error = voxel.value - u_rendering.threshold_value;

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;

