
float debug_ray_end_distance = map(box.min_entry_distance, box.max_exit_distance, ray.end_distance);

debug.ray_end_distance = vec4(vec3(debug_ray_end_distance), 1.0);
