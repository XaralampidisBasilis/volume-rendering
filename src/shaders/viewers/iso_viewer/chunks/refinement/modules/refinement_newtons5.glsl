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

// begin at initial guess and iterate from there
vec2 distance_bounds = vec2(prev_trace.distance, trace.distance);
float s_linear = map(prev_trace.value, trace.value, u_raycast.threshold);
trace.distance = mix(distance_bounds.x, distance_bounds.y, s_linear);

#pragma unroll_loop_start
for (int i = 0; i < 5; i++, trace.steps++) 
{
    // sample intensity at new position
    trace.position = ray.origin + ray.direction * trace.distance;
    trace.texel = trace.position * u_volume.inv_size;
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // compute the gradient and normal
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.gradient = - trace.normal * trace.gradient_norm;
    trace.derivative = dot(trace.gradient, ray.direction);

    // newton–raphson method to approximate next distance
    trace.distance -= trace.error / stabilize(trace.derivative);
    trace.distance = clamp(trace.distance, distance_bounds.x, distance_bounds.y);
}
#pragma unroll_loop_end

// if we do not have any improvement with refinement go to previous solution
if (abs(trace.error) > abs(temp_trace.error)) 
{
    copy_trace(trace, temp_trace);
}

