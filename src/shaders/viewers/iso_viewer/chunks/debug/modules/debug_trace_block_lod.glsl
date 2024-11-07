
float debug_trace_block_lod = float(trace.block_lod) / float(u_occumaps.lods);

debug.trace_block_lod = vec4(vec3(debug_trace_block_lod), 1.0);