
// normalize trace stepping to the range [0, 1]
float debug_ray_max_step_scaling = ray.max_step_scaling / u_raymarch.max_step_scaling;

debug.ray_max_step_scaling = vec4(vec3(debug_ray_max_step_scaling), 1.0);
