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
#include "./setup_trace_prev"

// define the bisection intervals
vec2 trace_samples = vec2(trace_prev.sample_value, trace.sample_value);
vec2 trace_distances = vec2(trace_prev.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.start_distance, ray.end_distance);

// #pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.step_count++) 
{
    // compute sample linear interpolation factor
    float lerp_threshold = map(trace_samples.x, trace_samples.y, u_raymarch.sample_threshold);

    // linearly interpolate positions based on sample 
    trace.distance = mix(trace_distances.x, trace_distances.y, lerp_threshold);
    trace.position = ray.origin_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // sample the intensity at the interpolated position
    #include "./update_volume_sample"

    // update bisection interval based on sample error sign
    float select_interval = step(0.0, trace.sample_error);

    trace_samples = mix(
        vec2(trace.sample_value, trace_samples.y), 
        vec2(trace_samples.x, trace.sample_value), 
    select_interval);

    trace_distances = mix(
        vec2(trace.distance, trace_distances.y), 
        vec2(trace_distances.x, trace.distance), 
    select_interval);
}
// #pragma unroll_loop_end

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.sample_error) > abs(trace_tmp.sample_error)) trace = trace_tmp;


