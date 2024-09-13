
float spacing = - trace.error / stabilize(trace.derivative);
float stepping = spacing / stabilize(ray.spacing);

trace.stepping = clamp(stepping, u_raycast.min_stepping, u_raycast.max_stepping);
trace.stepping = mix(u_raycast.max_stepping, trace.stepping, step(0.0, stepping));
