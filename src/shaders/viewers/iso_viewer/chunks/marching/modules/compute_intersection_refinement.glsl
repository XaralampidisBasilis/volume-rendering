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


// compute number of refinements
trace.step_distance = trace.distance - trace_prev.distance;
int refinements = int(ceil(log2(trace.step_distance / (ray.step_distance * MILLI_TOLERANCE))));
refinements = clamp(refinements, 5, 10);

// define the bisection intervals
// Define the initial bisection intervals
vec2 sample_bounds = clamp(vec2(trace_prev.sample_value, trace.sample_value), 0.0, 1.0);
vec2 distance_bounds = clamp(vec2(trace_prev.distance, trace.distance), ray.box_start_distance, ray.box_end_distance);

// save the initial trace state for potential rollback
Trace trace_tmp = trace;

// #pragma unroll_loop_start
for (int i = 0; i < refinements; i++) 
{
    // compute sample linear interpolation factor
    float mix_factor = map(sample_bounds.x, sample_bounds.y, u_raymarch.sample_threshold);

    // linearly interpolate positions based on sample 
    trace.distance = mix(distance_bounds.x, distance_bounds.y, mix_factor);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // sample the intensity at the interpolated position
    #include "./update_trace_sample"
    
     // Adjust bisection intervals based on the sample error sign
    float select = step(0.0, trace.sample_error);
    sample_bounds = mix(vec2(trace.sample_value, sample_bounds.y), vec2(sample_bounds.x, trace.sample_value), select);
    distance_bounds = mix(vec2(trace.distance, distance_bounds.y), vec2(distance_bounds.x, trace.distance), select);

    trace.step_count++;
}
// #pragma unroll_loop_end

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.sample_error) > abs(trace_tmp.sample_error)) trace = trace_tmp;

trace.step_distance = trace.distance - trace_prev.distance;