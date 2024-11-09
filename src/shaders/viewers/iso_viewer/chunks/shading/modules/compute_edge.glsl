
float viewing_angle = abs(dot(view_vector, normal_vector));
float edge_fading = smoothstep(0.0, u_shading.edge_contrast, viewing_angle);
 