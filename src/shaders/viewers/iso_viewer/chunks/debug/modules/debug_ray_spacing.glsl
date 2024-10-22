
// normalize ray spacing to the range [0, 1]
float debug_ray_spacing = ray.spacing / length(u_volume.spacing);

debug.ray_spacing = vec4(vec3(debug_ray_spacing), 1.0);
