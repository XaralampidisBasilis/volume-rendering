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
vec2 f = vec2(trace_prev.sample_value, trace.sample_value);
vec2 t = vec2(trace_prev.distance, trace.distance);
vec2 s = vec2(0.0, 1.0);

// Compute cubic lagrange coefficients
vec2 coeff = linear_coefficients(s, f); 

// Compute the roots of the equation L(s) - threshold = 0
coeff.x -= raymarch.sample_threshold;
float s_root = linear_roots(coeff);

// Filter normalized root outside of the s interval 
float s_filter = inside(s.x, s.y, s_root);
s_root = mix(s.y, s_root, s_filter);
s_root = clamp(s_root, s.x, s.y);

// Denormalize result
float t_root = mix(t.x, t.y, s_root);
t_root = clamp(t_root, ray.start_distance, ray.end_distance);

// Compute distance and position in solution
trace.distance = t_root;
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample volume
#include "./sample_volume