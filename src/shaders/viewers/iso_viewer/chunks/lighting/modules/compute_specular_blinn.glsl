
float shininess = u_lighting.shininess;
vec3 halfway_vector = normalize(light_vector + view_vector); 

specular = clamp(dot(halfway_vector, normal_vector), 0.0, 1.0);
specular = pow(specular, shininess) * u_lighting.ks;
specular_component = mix(trace.color, u_lighting.s_color, specular * u_lighting.ks);
specular_component = mmix(0.0, specular_component, step(0.0, lambertian));