
// normalize ray end position
vec3 debug_ray_end_position = ray.end_position * volume.inv_size;

debug.ray_end_position = vec4(vec3(debug_ray_end_position), 1.0);
