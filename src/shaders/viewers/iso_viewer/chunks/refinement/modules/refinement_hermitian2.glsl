/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param u_sampler: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// Define symbolic vectors
vec2 s = vec2(0.0, 1.0);
vec2 t = vec2(prev_trace.distance, trace.distance);
vec2 f = vec2(prev_trace.value, trace.value);
vec2 f_prime = vec2(prev_trace.derivative, trace.derivative);
f_prime *= t.y - t.x;

// Compute cubic hermite coefficients
vec4 coeff = hermite2_coefficients(s, f, f_prime);

// Compute the roots of the equation H(t) - threshold = 0
coeff.x -= u_raycast.threshold;
vec3 s_roots = cubic_roots(coeff);

// Filter normalized roots outside of the interval [0, 1] and set them to 1.0
vec3 s_filter = inside(s.xxx, s.yyy, s_roots);
s_roots = mix(s.yyy, s_roots, s_filter);
s_roots = clamp(s_roots, s.xxx, s.yyy);

// Denormalize result
vec3 t_roots = mix(t.xxx, t.yyy, s_roots);
t_roots = clamp(t_roots, ray.min_distance, ray.max_distance);

// Compute distance and position in solution
trace.distance = mmin(t_roots);
trace.position = ray.origin + ray.direction * trace.distance;

// Compute value and error
trace.texel = trace.position * u_volume.inv_size;
trace.value = texture(u_sampler.volume, trace.texel).r;
trace.error = trace.value - u_raycast.threshold;

// Compute gradient, and normal
vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
trace.gradient = (2.0 * gradient_data.rgb - 1.0) * u_gradient.max_norm;
trace.gradient_norm = length(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);
trace.normal = - normalize(trace.gradient);
trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;
