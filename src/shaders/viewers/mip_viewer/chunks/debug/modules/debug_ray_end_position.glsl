
// normalize ray end position
vec3 debug_ray_end_position = map(box.min_position, box.max_position, ray.end_position);

debug.ray_end_position = vec4(vec3(debug_ray_end_position), 1.0);
