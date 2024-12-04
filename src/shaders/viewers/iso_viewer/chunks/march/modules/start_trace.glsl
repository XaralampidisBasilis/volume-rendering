
// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;

// start step distance
trace.step_distance = 0.0;
trace.step_scaling = 1.0;
trace.step_stretching = 1.0;
