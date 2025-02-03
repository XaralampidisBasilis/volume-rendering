
float shadows_fading = smoothstep(0.0, u_lighting.shadows, max(frag.light_angle, 0.0));
shadows_fading = pow(shadows_fading, 1.0);
 