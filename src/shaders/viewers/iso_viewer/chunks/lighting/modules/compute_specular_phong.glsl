
float shininess = u_lighting.shininess * 0.25;
vec3 reflected_vector = - reflect(light_vector, normal_vector);

specular = clamp(dot(reflected_vector, view_vector), 0.0, 1.0);
specular = pow(specular, shininess);
specular_component = mix(trace.color, u_lighting.s_color, specular * u_lighting.ks);
specular_component = mmix(0.0, specular_component, step(0.0, lambertian));