

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
void refinement_lagrange
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
    // Define linear interpolation
    // float s_linear = rampstep(prev_trace.value, trace.value, u_raycast.threshold);
    highp float s_linear = 0.5;
    
    highp vec3 texel = mix(prev_trace.texel, trace.texel, s_linear);
    highp float depth = mix(prev_trace.depth, trace.depth, s_linear);
    highp float value = texture(u_sampler.volume, texel).r;

    // Define symbolic vectors
    highp vec3 t = vec3(prev_trace.depth, depth, trace.depth);
    highp vec3 f = vec3(prev_trace.value, value, trace.value);
    highp vec3 s = vec3(0.0, s_linear, 1.0); // for some reason if i include u_debug.scale the result changes dramatically event if it is 1

    // Compute cubic lagrange coefficients
    highp vec3 coeff = lagrange_coefficients(s, f); 

    // Compute the roots of the equation L(s) - threshold = 0
    coeff.x -= u_raycast.threshold;
    highp vec2 s_roots = quadratic_roots(coeff);

    // Filter normalized roots outside of the s interval 
    highp vec2 s_filter = step(s.xx, s_roots) * step(s_roots, s.zz);
    s_roots = mix(s.zz, s_roots, s_filter);
    s_roots = clamp(s_roots, s.xx, s.zz);

    // Denormalize result
    highp vec2 t_roots = mix(t.xx, t.zz, s_roots);
    t_roots = clamp(t_roots, ray.bounds.x, ray.bounds.y);

    // Compute depth and position in solution
    trace.depth = min(t_roots.x, t_roots.y);
    trace.position = ray.origin + ray.direction * trace.depth;

    // Compute value and error
    trace.texel = trace.position * u_volume.inv_size;
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // Compute gradient, and normal
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
    trace.gradient = trace.normal * trace.steepness;
}
