
vec3 debug_camera_position = map(box.min_position, box.max_position, camera.position);

debug.camera_position = vec4(debug_camera_position, 1.0);
