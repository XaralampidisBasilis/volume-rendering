
// normalize ray dithering to the range [0, 1]
float debug_ray_rand_distance = ray.rand_distance / u_volume.spacing_length;

debug.ray_rand_distance = vec4(vec3(debug_ray_rand_distance), 1.0);
