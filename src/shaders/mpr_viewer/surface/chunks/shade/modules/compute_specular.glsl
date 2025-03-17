
// https://learnwebgl.brown37.net/09_lights/lights_specular.html
float specular = clamp(frag.halfway_angle, 0.0, 1.0);
specular = pow(specular, u_shading.shininess) * u_shading.specular_reflectance;
frag.specular_color = mix(frag.color.rgb, COLOR.WHITE, specular * u_shading.specular_reflectance);
frag.specular_color = mix(COLOR.BLACK, frag.specular_color, step(0.0, lambertian));