

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

// Define linear interpolation
float s_linear = map(prev_trace.value, trace.value, u_raycast.threshold);
float s_sample = mix(0.5, s_linear, 0.5);

vec3 mix_texel = mix(prev_trace.texel, trace.texel, s_sample);
float mix_distance = mix(prev_trace.distance, trace.distance, s_sample);
float mix_value = texture(u_sampler.volume, mix_texel).r;

// Define symbolic vectors
vec3 f = vec3(prev_trace.value, mix_value, trace.value);
vec3 t = vec3(prev_trace.distance, mix_distance, trace.distance);
vec3 s = vec3(0.0, s_sample, 1.0);

// Compute cubic lagrange coefficients
vec3 coeff = lagrange3_coefficients(s, f); 

// Compute the roots of the equation L(s) - threshold = 0
coeff.x -= u_raycast.threshold;
vec2 s_roots = quadratic_roots(coeff);

// Filter normalized roots outside of the s interval 
vec2 s_filter = inside(s.xx, s.zz, s_roots);
s_roots = mix(s.zz, s_roots, s_filter);
s_roots = clamp(s_roots, s.xx, s.zz);

// Denormalize result
vec2 t_roots = mix(t.xx, t.zz, s_roots);
t_roots = clamp(t_roots, ray.min_distance, ray.max_distance);

// Compute distance and position in solution
trace.distance = mmin(t_roots);
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * u_volume.inv_size;

// Extract intensity value from volume data
vec4 volume_data = texture(u_sampler.volume, trace.texel);
trace.value = volume_data.r;
trace.error = trace.value - u_raycast.threshold;

// Extract gradient from volume data
trace.gradient = (2.0 * volume_data.gba - 1.0) * u_gradient.max_norm;
trace.gradient_norm = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);

trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;