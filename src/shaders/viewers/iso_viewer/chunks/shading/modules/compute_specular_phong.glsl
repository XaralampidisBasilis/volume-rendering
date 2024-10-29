//https://learnwebgl.brown37.net/09_lights/lights_specular.html

float shininess = u_shading.shininess * 0.25;
vec3 reflected_vector = - reflect(light_vector, normal_vector);

float specular = clamp(dot(reflected_vector, view_vector), 0.0, 1.0);
specular = pow(specular, shininess);

vec3 specular_component = mix(trace.color, lighting.color_s, specular * u_shading.reflectance_s);
specular_component = mmix(0.0, specular_component, step(0.0, lambertian));