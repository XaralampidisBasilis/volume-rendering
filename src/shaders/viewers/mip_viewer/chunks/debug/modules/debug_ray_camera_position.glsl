
vec3 debug_ray_camera_position;
intersect_box_min(ray.box_min_position, ray.box_max_position, ray.camera_position, ray.camera_direction, debug_ray_camera_position);
debug_ray_camera_position /= ray.box_max_position;

debug.ray_camera_position = vec4(debug_ray_camera_position, 1.0);
