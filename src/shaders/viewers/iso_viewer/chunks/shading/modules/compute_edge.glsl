
float viewing_angle = abs(dot(view_vector, normal_vector));
float edge_fading = softstep(0.0, shading.edge_contrast, viewing_angle);
 