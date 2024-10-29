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

// save not refined solution
Trace trace_tmp = trace;

// define the bisection intervals
vec2 trace_samples = vec2(trace_prev.sample_value, trace.sample_value);
vec2 trace_distances = vec2(trace_prev.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.start_distance, ray.end_distance);

float sample_lerp;
float select_interval;
vec4 volume_texture_data;

#pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.step_count++) 
{
    // compute sample linear interpolation factor
    sample_lerp = map(trace_samples.x, trace_samples.y, raymarch.sample_threshold);

    // linearly interpolate positions based on sample 
    trace.distance = mix(trace_distances.x, trace_distances.y, sample_lerp);
    trace.position = ray.origin_position + ray.step_direction * trace.distance;
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // sample the intensity at the interpolated position
    volume_texture_data = texture(textures.volume, trace.voxel_texture_coords);
    trace.sample_value = volume_texture_data.r;
    trace.sample_error = trace.sample_value - raymarch.sample_threshold;

    // update bisection interval based on sample error sign
    select_interval = step(0.0, trace.sample_error);

    trace_samples = mix(
        vec2(trace.sample_value, trace_samples.y), 
        vec2(trace_samples.x, trace.sample_value), 
    select_interval);

    trace_distances = mix(
        vec2(trace.distance, trace_distances.y), 
        vec2(trace_distances.x, trace.distance), 
    select_interval);
}
#pragma unroll_loop_end

// update trace
trace.voxel_coords = int(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

trace.gradient = mix(volume.min_gradient, volume.max_gradient, volume_texture_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.normal = -trace.gradient_direction;
#include "../../derivatives/compute_derivatives"

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.sample_error) > abs(trace_tmp.sample_error)) trace = trace_tmp;


