
float debug_frag_light_angle = map(-1.0, 1.0, frag.light_angle);

debug.frag_light_angle = vec4(vec3(debug_frag_light_angle), 1.0);