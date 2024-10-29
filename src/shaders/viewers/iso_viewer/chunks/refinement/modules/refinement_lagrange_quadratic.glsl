

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

// Define linear interpolation
float s_linear = map(trace_prev.sample_value, trace.sample_value, raymarch.sample_threshold);
float s_sample = mix(0.5, s_linear, 0.5);

vec3 trace_voxel_texture_coords = mix(trace_prev.voxel_texture_coords, trace.voxel_texture_coords, s_sample);
float trace_distance = mix(trace_prev.distance, trace.distance, s_sample);
float trace_sample_value = texture(textures.volume, trace_voxel_texture_coords).r;

// Define symbolic vectors
vec3 f = vec3(trace_prev.sample_value, trace_sample_value, trace.sample_value);
vec3 t = vec3(trace_prev.distance, trace_distance, trace.distance);
vec3 s = vec3(0.0, s_sample, 1.0);

// Compute cubic lagrange coefficients
vec3 coeff = lagrange_quadratic_coefficients(s, f); 

// Compute the roots of the equation L(s) - threshold = 0
coeff.x -= raymarch.sample_threshold;
vec2 s_roots = quadratic_roots(coeff);

// Filter normalized roots outside of the s interval 
vec2 s_filter = inside(s.xx, s.zz, s_roots);
s_roots = mix(s.zz, s_roots, s_filter);
s_roots = clamp(s_roots, s.xx, s.zz);

// Denormalize result
vec2 t_roots = mix(t.xx, t.zz, s_roots);
t_roots = clamp(t_roots, ray.start_distance, ray.end_distance);

// Compute distance and position in solution
trace.distance = mmin(t_roots);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample volume
#include "./sample_volume