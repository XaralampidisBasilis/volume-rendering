
// normalize ray max distance to the range [0, 1]
float debug_ray_box_end_distance = map(ray.box_min_distance, ray.box_max_distance, ray.box_end_distance);

debug.ray_box_end_distance = vec4(vec3(debug_ray_box_end_distance), 1.0);
