
trace.stepping = - trace.error / maxabs(trace.derivative, EPSILON6);
trace.stepping /= ray.spacing;
trace.stepping = mix(u_raycast.max_stepping, trace.stepping, step(0.0, trace.stepping));
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);
