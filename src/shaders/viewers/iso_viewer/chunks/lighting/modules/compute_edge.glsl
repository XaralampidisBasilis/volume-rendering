
float viewing_angle = abs(dot(view_vector, normal_vector));
float edge_factor = pow(1.0 - viewing_angle, 0.3);

edge_fading = mix(0.0, pow(map(u_lighting.edge_threshold, 1.0, edge_factor), 6.0), step(u_lighting.edge_threshold, edge_factor));


 