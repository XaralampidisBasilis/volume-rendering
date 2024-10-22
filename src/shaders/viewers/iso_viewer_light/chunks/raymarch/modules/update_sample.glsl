
// Extract intensity and gradient from volume data in a single texture lookup
vec4 volume_data = texture(u_sampler.volume, trace.texel);
trace.value = volume_data.r;
trace.error = trace.value - raycast_threshold;

// Compute the gradient and its norm in a single step
trace.gradient = mix(u_gradient.min, u_gradient.max, volume_data.gba);
trace.normal = -normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);
