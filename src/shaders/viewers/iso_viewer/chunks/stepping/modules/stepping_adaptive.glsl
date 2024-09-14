
float spacing = - trace.error / maxabs(trace.derivative, EPSILON6);
float stepping = spacing / maxabs(ray.spacing, EPSILON6);

trace.stepping = clamp(stepping, u_raycast.min_stepping, u_raycast.max_stepping);
trace.stepping = mix(u_raycast.max_stepping, trace.stepping, step(0.0, stepping));
