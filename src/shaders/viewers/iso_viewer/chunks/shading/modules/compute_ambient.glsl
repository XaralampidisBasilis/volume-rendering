
// https://learnwebgl.brown37.net/09_lights/lights_ambient.html
vec3 ambient_component = shading.ambient_reflectance * lighting.ambient_color * trace.mapped_color;
