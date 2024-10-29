/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param raymarch: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param u_sampler: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// Define linear interpolation
float s_linear = map(trace_prev.sample, trace.sample, raymarch.sample_threshold);
vec2 s_sample = mix(vec2(0.25, s_linear), vec2(s_linear, 0.75), 0.5);

// sample distances and values at samples
vec3 mix_texel_x = mix(trace_prev.texel, trace.voxel_texture_coords, s_sample.x);
vec3 mix_texel_y = mix(trace_prev.texel, trace.voxel_texture_coords, s_sample.y);
vec2 mix_distances = mix(vec2(trace_prev.distance), vec2(trace.distance), s_sample);
vec2 mix_values = vec2(texture(u_sampler.volume, mix_texel_x).r, texture(u_sampler.volume, mix_texel_y).r);

// Define symbolic vectors
vec4 f = vec4(trace_prev.sample, mix_values, trace.sample);
vec4 t = vec4(trace_prev.distance, mix_distances, trace.distance);
vec4 s = vec4(0.0, s_sample, 1.0);

// Compute cubic hermite coefficients
vec4 coeff = lagrange_cubic_coefficients(s, f);

// Compute the roots of the equation L(s) = threshold
coeff.x -= raymarch.sample_threshold;
vec3 s_roots = cubic_roots(coeff);

// Filter normalized roots outside of the interval [0, 1] and set them to 1.0
vec3 s_filter = inside(s.xxx, s.www, s_roots);
s_roots = mix(s.www, s_roots, s_filter);
s_roots = clamp(s_roots, s.xxx, s.www);

// Denormalize result
vec3 t_roots = mix(t.xxx, t.www, s_roots);
t_roots = clamp(t_roots, ray.start_distance, ray.end_distance);

// Compute distance and position in solution
trace.distance = mmin(t_roots);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// Extract intensity value from volume data
vec4 volume_data = texture(u_sampler.volume, trace.voxel_texture_coords);
trace.sample = volume_data.r;
trace.sample_error = trace.sample - raymarch.sample_threshold;

// Extract gradient from volume data
trace.gradient = mix(volume.min_gradient, volume.max_gradient, volume_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

trace.voxel_coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.start_distance;