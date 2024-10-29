
// https://learnwebgl.brown37.net/09_lights/lights_ambient.html
vec3 ambient_component = u_shading.reflectance_a * lighting.color_a * trace.color;
