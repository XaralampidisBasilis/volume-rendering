
float alignment = max(dot(-trace.normal, ray.direction), 0.0);
trace.stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, alignment);


