
vec3 debug_frag_normal_vector = frag.normal_vector * 0.5 + 0.5;

debug.frag_normal_vector = vec4(debug_frag_normal_vector, 1.0);
