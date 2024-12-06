
float lighting_angle = max(dot(frag.light_vector, frag.normal_vector), 0.0);
float shadows_fading = smoothstep(0.0, u_lighting.shadows, lighting_angle);
shadows_fading = pow(shadows_fading, 1.0);
 