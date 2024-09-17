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
vec2 f = vec2(prev_trace.value, trace.value);
vec2 t = vec2(prev_trace.distance, trace.distance);
vec2 s = vec2(0.0, 1.0);

// Compute cubic lagrange coefficients
vec2 coeff = linear2_coefficients(s, f); 

// Compute the roots of the equation L(s) - threshold = 0
coeff.x -= u_raycast.threshold;
float s_root = linear_root(coeff);

// Filter normalized root outside of the s interval 
float s_filter = inside(s.x, s.y, s_root);
s_root = mix(s.y, s_root, s_filter);
s_root = clamp(s_root, s.x, s.y);

// Denormalize result
float t_root = mix(t.x, t.y, s_root);
t_root = clamp(t_root, ray.min_distance, ray.max_distance);

// Compute distance and position in solution
trace.distance = t_root;
trace.position = ray.origin + ray.direction * trace.distance;

// Compute value and error
trace.texel = trace.position * u_volume.inv_size;
trace.value = texture(u_sampler.volume, trace.texel).r;
trace.error = trace.value - u_raycast.threshold;

// Compute gradient, and normal
vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
trace.gradient = - trace.normal * trace.gradient_norm;
trace.derivative = dot(trace.gradient, ray.direction);
trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;


