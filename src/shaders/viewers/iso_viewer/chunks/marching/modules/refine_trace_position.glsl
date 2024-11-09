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

// sample the volume at previous step distance
#include "./start_trace_prev"

// define the bisection intervals
vec2 trace_samples = vec2(trace_prev.sample_value, trace.sample_value);
vec2 trace_distances = vec2(trace_prev.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.start_distance, ray.end_distance);

// #pragma unroll_loop_start
for (int i = 0; i < 5; i++) 
{
    // compute sample linear interpolation factor
    float lerp = map(trace_samples.x, trace_samples.y, u_raymarch.sample_threshold);

    // linearly interpolate positions based on sample 
    trace.distance = mix(trace_distances.x, trace_distances.y, lerp);
    trace.position = ray.origin_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // sample the intensity at the interpolated position
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;
    trace.sample_error = trace.sample_value - u_raymarch.sample_threshold;

    // sample the gradient at the interpolated position
    trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
    trace.gradient_magnitude = length(trace.gradient);
    trace.gradient_direction = normalize(trace.gradient);
    trace.derivative = dot(trace.gradient, ray.step_direction);
    trace.normal = -trace.gradient_direction;

    // update bisection interval based on sample error sign
    float select = step(0.0, trace.sample_error);

    trace_samples = mix(
        vec2(trace.sample_value, trace_samples.y), 
        vec2(trace_samples.x, trace.sample_value), 
    select);

    trace_distances = mix(
        vec2(trace.distance, trace_distances.y), 
        vec2(trace_distances.x, trace.distance), 
    select);

    trace.step_count++;
}
// #pragma unroll_loop_end

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.sample_error) > abs(trace_tmp.sample_error)) trace = trace_tmp;


