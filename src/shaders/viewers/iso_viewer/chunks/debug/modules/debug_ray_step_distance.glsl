
// normalize ray spacing to the range [0, 1]
float debug_ray_step_distance = ray.step_distance / length(u_volume.spacing);

debug.ray_step_distance = vec4(vec3(debug_ray_step_distance), 1.0);
