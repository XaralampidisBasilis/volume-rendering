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
parameters_trace temp_trace = trace;

// begin at initial guess and iterate from there
vec2 distances = vec2(trace_prev.distance, trace.distance);
distances = clamp(distances, ray.start_distance, ray.end_distance);

float s_linear = map(trace_prev.sample_value, trace.sample_value, raymarch.sample_threshold);
trace.distance = mix(distances.x, distances.y, s_linear);

vec4 volume_data;

#pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.step_count++) 
{
    // sample intensity at new position
    trace.position = ray.origin_position + ray.step_direction * trace.distance;
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // Extract intensity value from volume data
    volume_data = texture(textures.volume, trace.voxel_texture_coords);
    trace.sample_value = volume_data.r;
    trace.sample_error = trace.sample_value - raymarch.sample_threshold;

    // Extract gradient from volume data
    trace.gradient = mix(volume.min_gradient, volume.max_gradient, volume_data.gba);
    trace.gradient_magnitude = length(trace.gradient);
    trace.normal = - normalize(trace.gradient);
    trace.derivative_1st = dot(trace.gradient, ray.step_direction);

    // newton–raphson method to approximate next distance
    trace.distance -= trace.sample_error / stabilize(trace.derivative_1st);
    trace.distance = clamp(trace.distance, distances.x, distances.y);
}
#pragma unroll_loop_end

trace.voxel_coords = floor(trace.position * volume.inv_spacing);

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.sample_error) > abs(temp_trace.error)) {
    trace = temp_trace;
}

