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
vec2 s_sample = mix(vec2(0.25, s_linear), vec2(s_linear, 0.75), 0.5);

// sample distances and values at samples
vec3 voxel_texture_coords_x = mix(trace_prev.voxel_texture_coords, trace.voxel_texture_coords, s_sample.x);
vec3 voxel_texture_coords_y = mix(trace_prev.voxel_texture_coords, trace.voxel_texture_coords, s_sample.y);

vec2 trace_distances = mix(
    vec2(trace_prev.distance), 
    vec2(trace.distance), 
s_sample);

vec2 trace_sample_values = vec2(
    texture(textures.volume, voxel_texture_coords_x).r, 
    texture(textures.volume, voxel_texture_coords_y).r
);

// Define symbolic vectors
vec4 f = vec4(trace_prev.sample_value, trace_sample_values, trace.sample_value);
vec4 t = vec4(trace_prev.distance, trace_distances, trace.distance);
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
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample volume
#include "./sample_volume