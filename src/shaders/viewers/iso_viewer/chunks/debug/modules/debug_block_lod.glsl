
float block_lod = float(block.lod) / float(u_occupancy.lods - 1);

debug.block_lod = vec4(vec3(block_lod), 1.0);