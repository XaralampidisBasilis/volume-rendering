
float debug_ray_step_distance = ray.step_distance / u_volume.spacing_length;

debug.ray_step_distance = vec4(vec3(debug_ray_step_distance), 1.0);
