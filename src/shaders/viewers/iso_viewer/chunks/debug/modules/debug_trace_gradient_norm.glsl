
// normalize trace gradient norm to the range [0, 1]
float trace_gradient_norm_normalized = map(u_gradient.min_norm, u_gradient.max_norm, trace.gradient_norm);

// map trace gradient norm to a color using the "cool" colormap from datoviz texture 
vec2 trace_gradient_norm_uv = vec2(mix(127.5/256.0, 255.5/256.0, trace_gradient_norm_normalized), 48.5/256.0); // flipped left spectral colormap
vec3 trace_gradient_norm_color = texture(u_sampler.colormap, trace_gradient_norm_uv).rgb;

debug.trace_gradient_norm = vec4(vec3(trace_gradient_norm_normalized), 1.0);
