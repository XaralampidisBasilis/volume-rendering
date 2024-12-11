
// current position
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.block_coords = ivec3(trace.position * u_extremap.inv_spacing);

// update trace extrema block values
trace.block_min_value = texelFetch(u_textures.extremap, trace.block_coords, 0).r; 
trace.block_max_value = texelFetch(u_textures.extremap, trace.block_coords, 0).g; 
trace.block_occupied = max_trace.sample_value < trace.block_max_value;
