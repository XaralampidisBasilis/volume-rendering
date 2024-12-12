
float debug_frag_camera_angle = acos(frag.camera_angle) / PI;

debug.frag_camera_angle = vec4(vec3(debug_frag_camera_angle), 1.0);