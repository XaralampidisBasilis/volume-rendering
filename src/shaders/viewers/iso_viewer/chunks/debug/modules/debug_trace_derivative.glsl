

// normalize trace derivative to the range [0, 1]
float trace_derivative_norm = map(-1.0, 1.0, trace.derivative / u_gradient.max_norm);

// map trace derivative to a color using the a colormap from datoviz texture 
vec2 trace_derivative_uv = vec2(mix(255.5/256.0, 0.5/256.0, trace_derivative_norm), 48.5/256.0); // flipped spectral colormap
vec3 trace_derivative_color = texture(u_sampler.colormap, trace_derivative_uv).rgb;

debug.trace_derivative = vec4(vec3(trace_derivative_norm), 1.0);
