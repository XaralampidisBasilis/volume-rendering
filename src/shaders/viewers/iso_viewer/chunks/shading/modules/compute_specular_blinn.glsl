// https://learnwebgl.brown37.net/09_lights/lights_specular.html

float shininess = shading.shininess;
vec3 halfway_vector = normalize(light_vector + view_vector); 

float specular = clamp(dot(halfway_vector, normal_vector), 0.0, 1.0);
specular = pow(specular, shininess) * shading.specular_reflectance;

vec3 specular_component = mix(trace.mapped_color, lighting.specular_color, specular * shading.specular_reflectance);
specular_component = mmix(0.0, specular_component, step(0.0, lambertian));