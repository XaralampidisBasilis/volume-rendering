
float debug_ray_start_distance = map(box.min_entry_distance, box.max_exit_distance, ray.start_distance);

debug.ray_start_distance = vec4(vec3(debug_ray_start_distance), 1.0);
