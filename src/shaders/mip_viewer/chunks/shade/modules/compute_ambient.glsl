
// https://learnwebgl.brown37.net/09_lights/lights_ambient.html
frag.ambient_color = u_shading.ambient_reflectance * u_lighting.ambient_color * frag.mapped_color.rgb;
