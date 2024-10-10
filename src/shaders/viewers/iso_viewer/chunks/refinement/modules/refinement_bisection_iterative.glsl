/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param u_raycast: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param u_sampler: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// save not refined solution
parameters_trace temp_trace;
copy_trace(temp_trace, trace);

// define the bisection intervals
vec2 values = vec2(prev_trace.value, trace.value);
vec2 distances = vec2(prev_trace.distance, trace.distance);
distances = clamp(distances, ray.min_distance, ray.max_distance);

float mix_error;
float is_positive;
vec4 volume_data;

#pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.steps++) 
{
    // compute interpolation factor
    mix_error = map(values.x, values.y, u_raycast.threshold);

    // compute position
    trace.distance = mix(distances.x, distances.y, mix_error);
    trace.position = ray.origin + ray.direction * trace.distance;
    trace.texel = trace.position * u_volume.inv_size;

    // sample the intensity at the interpolated position
    volume_data = texture(u_sampler.volume, trace.texel);
    trace.value = volume_data.r;
    trace.error = trace.value - u_raycast.threshold;

    // Update position and value based on error
    is_positive = step(0.0, trace.error);
    values = mix(vec2(trace.value, values.y), vec2(values.x, trace.value), is_positive);
    distances = mix(vec2(trace.distance, distances.y), vec2(distances.x, trace.distance), is_positive);
    trace.steps++;
}
#pragma unroll_loop_end

// Compute the gradient and additional properties
trace.gradient = mix(u_gradient.min, u_gradient.max, volume_data.gba);
trace.gradient_norm = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.direction);

trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.error) > abs(temp_trace.error)) {
    copy_trace(trace, temp_trace);
}


