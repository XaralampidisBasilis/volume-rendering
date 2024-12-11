
vec3 debug_ray_start_position =  map(box.min_position, box.max_position, ray.start_position);

debug.ray_start_position = vec4(vec3(debug_ray_start_position), 1.0);
