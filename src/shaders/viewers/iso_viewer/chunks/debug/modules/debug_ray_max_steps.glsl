
// normalize ray max steps in the range [0, 1]
float ray_max_steps_norm = float(ray.max_steps) / float(u_raycast.max_steps);

debug.ray_max_steps = vec4(vec3(ray_max_steps_norm), 1.0);
