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
void refinement_lagrange4
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
    float s_linear = map(prev_trace.value, trace.value, u_raycast.threshold);
    vec2 s_sample = mix(vec2(0.25, s_linear), vec2(s_linear, 0.75), 0.5);

    // sample distances and values at samples
    vec3 texel_x = mix(prev_trace.texel, trace.texel, s_sample.x);
    vec3 texel_y = mix(prev_trace.texel, trace.texel, s_sample.y);
    vec2 distances = mix(vec2(prev_trace.distance), vec2(trace.distance), s_sample);
    vec2 values = vec2(texture(u_sampler.volume, texel_x).r, texture(u_sampler.volume, texel_y).r);

    // Define symbolic vectors
    vec4 f = vec4(prev_trace.value, values, trace.value);
    vec4 t = vec4(prev_trace.distance, distances, trace.distance);
    vec4 s = vec4(0.0, s_sample, 1.0);

    // Compute cubic hermite coefficients
    vec4 coeff = lagrange4_coefficients(s, f);

    // Compute the roots of the equation L(s) = threshold
    coeff.x -= u_raycast.threshold;
    vec3 s_roots = cubic_roots(coeff);

    // Filter normalized roots outside of the interval [0, 1] and set them to 1.0
    vec3 s_filter = inside(s.xxx, s.www, s_roots);
    s_roots = mix(s.www, s_roots, s_filter);
    s_roots = clamp(s_roots, s.xxx, s.www);

    // Denormalize result
    vec3 t_roots = mix(t.xxx, t.www, s_roots);
    t_roots = clamp(t_roots, ray.min_distance, ray.max_distance);

    // Compute distance and position in solution
    trace.distance = mmin(t_roots);
    trace.position = ray.origin + ray.direction * trace.distance;

    // Compute value and error
    trace.texel = trace.position * u_volume.inv_size;
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // Compute gradient, and normal
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.gradient = - trace.normal * trace.gradient_norm;
    trace.derivative = dot(trace.gradient, ray.direction);
}
