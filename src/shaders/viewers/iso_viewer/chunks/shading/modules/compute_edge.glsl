
float viewing_angle = abs(dot(view_vector, normal_vector));
float edge_fading = softstep(0.0, u_shading.edge_threshold, viewing_angle);
 