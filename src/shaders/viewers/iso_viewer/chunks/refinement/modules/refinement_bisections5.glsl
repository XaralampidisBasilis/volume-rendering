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

#pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.steps++) 
{
    // compute interpolation factor
    float s = map(values.x, values.y, u_raycast.threshold);

    trace.distance = mix(distances.x, distances.y, s);
    trace.position = ray.origin + ray.direction * trace.distance;
    trace.texel = trace.position * u_volume.inv_size;

    // sample the intensity at the interpolated position
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // Update position and value based on error
    float is_positive = step(0.0, trace.error);
    values = mix(vec2(trace.value, values.y), vec2(values.x, trace.value), is_positive);
    distances = mix(vec2(trace.distance, distances.y), vec2(distances.x, trace.distance), is_positive);
}
#pragma unroll_loop_end

// Compute the gradient and additional properties
vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
trace.gradient = - trace.normal * trace.gradient_norm;
trace.derivative = dot(trace.gradient, ray.direction);

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.error) > abs(temp_trace.error)) 
{
    copy_trace(trace, temp_trace);
}


