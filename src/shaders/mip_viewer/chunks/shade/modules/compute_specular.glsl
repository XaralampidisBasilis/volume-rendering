// https://learnwebgl.brown37.net/09_lights/lights_specular.html

float specular = clamp(frag.halfway_angle, 0.0, 1.0);
specular = pow(specular, u_shading.shininess) * u_shading.specular_reflectance;

frag.specular_color = mix(frag.mapped_color.rgb, u_lighting.specular_color, specular * u_shading.specular_reflectance);
frag.specular_color = mmix(0.0, frag.specular_color, step(0.0, lambertian));