
lambertian = map(u_lighting.shadows - 1.0, 1.0, dot(normal_vector, light_vector));
diffuse_component = lambertian * u_lighting.kd * u_lighting.d_color * trace.color;
diffuse_component *= 1.0 - edge_fading;
