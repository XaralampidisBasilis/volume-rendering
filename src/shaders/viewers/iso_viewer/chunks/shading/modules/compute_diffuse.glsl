// https://learnwebgl.brown37.net/09_lights/lights_diffuse.html

float lambertian = max(dot(normal_vector, light_vector), 0.0);
vec3 diffuse_component = lambertian * u_shading.reflectance_d * lighting.color_d * trace.color;
// diffuse_component *= 1.0 - edge_fading;
