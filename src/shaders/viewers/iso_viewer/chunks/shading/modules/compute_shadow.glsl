
float lighting_angle = max(dot(light_vector, normal_vector), 0.0);
float shadows_fading = smoothstep(0.0, lighting.shadows, lighting_angle);
shadows_fading = pow(shadows_fading, 1.0);
 