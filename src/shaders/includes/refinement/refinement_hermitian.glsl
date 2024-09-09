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

highp float epsilon = 1e-5;  // Small tolerance to handle precision issues

void refinement_hermitian
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
    // Define symbolic vectors
    highp vec2 s = vec2(0.0, 1.0);
    highp vec2 t = vec2(prev_trace.depth, trace.depth);
    highp vec2 f = vec2(prev_trace.value, trace.value);
    highp vec2 f_prime = vec2(dot(prev_trace.gradient, ray.direction), dot(trace.gradient, ray.direction));
    f_prime *= t.y - t.x;

    // Compute cubic hermite coefficients
    highp vec4 coeff = hermite_coefficients(s, f, f_prime);

    // Compute the roots of the equation H(t) - threshold = 0
    coeff.x -= u_raycast.threshold;
    highp vec3 s_roots = cubic_roots(coeff);

    // Filter normalized roots outside of the interval [0, 1] and set them to 1.0
    highp vec3 s_filter = step(s.xxx, s_roots) * step(s_roots, s.yyy);
    s_roots = mix(s.yyy, s_roots, s_filter);
    s_roots = clamp(s_roots, s.xxx, s.yyy);

    // Denormalize result
    highp vec3 t_roots = mix(t.xxx, t.yyy, s_roots);
    t_roots = clamp(t_roots, ray.bounds.x, ray.bounds.y);

    // Compute depth and position in solution
    trace.depth = min(t_roots.x, min(t_roots.y, t_roots.z));
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
