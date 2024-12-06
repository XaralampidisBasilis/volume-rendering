// https://learnwebgl.brown37.net/09_lights/lights_specular.html

float shininess = u_shading.shininess;
frag.halfway_vector = normalize(frag.light_vector + frag.view_vector); 

float specular = clamp(dot(frag.halfway_vector, frag.normal_vector), 0.0, 1.0);
specular = pow(specular, shininess) * u_shading.specular_reflectance;

vec3 specular_color = mix(frag.mapped_color.rgb, u_lighting.specular_color, specular * u_shading.specular_reflectance);
specular_color = mmix(0.0, specular_color, step(0.0, lambertian));