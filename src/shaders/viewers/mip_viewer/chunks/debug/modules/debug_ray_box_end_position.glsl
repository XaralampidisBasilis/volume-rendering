
// normalize ray end position
vec3 debug_ray_box_end_position = ray.box_end_position * u_volume.inv_size;

debug.ray_box_end_position = vec4(vec3(debug_ray_box_end_position), 1.0);
