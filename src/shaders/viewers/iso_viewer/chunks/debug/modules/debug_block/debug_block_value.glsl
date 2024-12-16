
float debug_block_value = float(block.value) / float(u_distmap.max_distance);

debug.block_value = vec4(vec3(debug_block_value), 1.0);