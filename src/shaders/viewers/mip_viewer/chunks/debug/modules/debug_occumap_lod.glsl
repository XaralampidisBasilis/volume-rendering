
float debug_occumap_lod = float(occumap.lod) / float(u_occumaps.lods);

debug.occumap_lod = vec4(vec3(debug_occumap_lod), 1.0);