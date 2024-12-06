
float viewing_angle = abs(dot(frag.view_vector, frag.normal_vector));
float edge_fading = smoothstep(0.0, u_shading.edge_contrast, viewing_angle);
 