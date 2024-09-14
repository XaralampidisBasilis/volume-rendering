
// normalize ray dithering to the range [0, 1]
float ray_dithering_norm = ray.dithering / ray.max_spacing;

debug.ray_dithering = vec4(vec3(ray_dithering_norm), 1.0);
