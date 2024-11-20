

// find block coords of trace position in maximap
trace.block_coords = ivec3(trace.position * u_maximap.inv_spacing);

// sample the occumaps atlas and check if block is occupied
trace.block_value = texelFetch(u_textures.maximap, trace.block_coords, 0).r;
trace.block_occupied = max_trace.sample_value < trace.block_value;
