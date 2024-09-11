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
void refinement_bisections5
(
    in uniforms_volume u_volume, 
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient,
    in uniforms_sampler u_sampler, 
    in parameters_ray ray,
    inout parameters_trace trace,
    inout parameters_trace prev_trace
)
{
    // save not refined solution
    parameters_trace temp_trace;
    copy_trace(temp_trace, trace);

    // define the bisection intervals
    vec2 values = vec2(prev_trace.value, trace.value);
    vec2 depths = vec2(prev_trace.depth, trace.depth);

    for (int i = 0; i < 5; i++) 
    {
        // compute interpolation factor
        float s = map(values.x, values.y, u_raycast.threshold);

        trace.depth = mix(depths.x, depths.y, s);
        trace.position = ray.origin + ray.direction * trace.depth;
        trace.texel = trace.position * u_volume.inv_size;

        // sample the intensity at the interpolated position
        trace.value = texture(u_sampler.volume, trace.texel).r;
        trace.error = trace.value - u_raycast.threshold;

        // Update position and value based on error
        float is_positive = step(0.0, trace.error);
        values = mix(vec2(trace.value, values.y), vec2(values.x, trace.value), is_positive);
        depths = mix(vec2(trace.depth, depths.y), vec2(depths.x, trace.depth), is_positive);
    }

    // Compute the gradient and additional properties
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
    trace.gradient = trace.normal * trace.steepness;

      // if we do not have any improvement with refinement go to previous solution
    if (abs(trace.error) > abs(temp_trace.error)) {
        copy_trace(trace, temp_trace);
    }

    return;
}
