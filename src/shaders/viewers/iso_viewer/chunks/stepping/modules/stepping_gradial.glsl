
float derivative = max(trace.derivative, 0.0);
derivative = map(u_gradient.min_norm, u_gradient.max_norm, derivative);
trace.stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, derivative);
