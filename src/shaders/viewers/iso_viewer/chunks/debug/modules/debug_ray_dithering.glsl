
// normalize ray dithering to the range [0, 1]
float debug_ray_dithering = ray.dithering / ray.max_spacing;

debug.ray_dithering = vec4(vec3(debug_ray_dithering), 1.0);
