
vec3 debug_frag_light_vector = frag.light_vector * 0.5 + 0.5;

debug.frag_light_vector = vec4(debug_frag_light_vector, 1.0);
