
trace.distance = ray.start_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.position = ray.start_position; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;

