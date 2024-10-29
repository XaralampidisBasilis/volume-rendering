/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param raymarch: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param textures: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// Define symbolic vectors
vec2 s = vec2(0.0, 1.0);
vec2 t = vec2(trace_prev.distance, trace.distance);
vec2 f = vec2(trace_prev.sample_value, trace.sample_value);
vec2 f_prime = vec2(trace_prev.derivative_1st, trace.derivative_1st);
f_prime *= t.y - t.x;

// Compute cubic hermite coefficients
vec4 coeff = hermite_cubic_coefficients(s, f, f_prime);

// Compute the roots of the equation H(t) - threshold = 0
coeff.x -= raymarch.sample_threshold;
vec3 s_roots = cubic_roots(coeff);

// Filter normalized roots outside of the interval [0, 1] and set them to 1.0
vec3 s_filter = inside(s.xxx, s.yyy, s_roots);
s_roots = mix(s.yyy, s_roots, s_filter);
s_roots = clamp(s_roots, s.xxx, s.yyy);

// Denormalize result
vec3 t_roots = mix(t.xxx, t.yyy, s_roots);
t_roots = clamp(t_roots, ray.start_distance, ray.end_distance);

// Compute distance and position in solution
trace.distance = mmin(t_roots);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample volume
#include "./sample_volume"