
vec3 debug_block_step_coords = (vec3(block.step_coords) / float(u_distmap.max_distance)) * 0.5 + 0.5;

debug.block_step_coords  = vec4(debug_block_step_coords, 1.0);