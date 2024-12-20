// https://learnwebgl.brown37.net/09_lights/lights_specular.html

float shininess = u_shading.shininess;
vec3 halfway_vector = normalize(light_vector + view_vector); 

float specular = clamp(dot(halfway_vector, normal_vector), 0.0, 1.0);
specular = pow(specular, shininess) * u_shading.reflectance_s;

vec3 specular_component = mix(trace.color, u_lighting.color_s, specular * u_shading.reflectance_s);
specular_component = mmix(0.0, specular_component, step(0.0, lambertian));