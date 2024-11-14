
// normalize ray start position
vec3 debug_ray_start_position = ray.start_position * u_volume.inv_size;

debug.ray_start_position = vec4(vec3(debug_ray_start_position), 1.0);
