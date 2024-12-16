
vec3 debug_frag_halfway_vector = frag.halfway_vector * 0.5 + 0.5;

debug.frag_halfway_vector = vec4(debug_frag_halfway_vector, 1.0);
