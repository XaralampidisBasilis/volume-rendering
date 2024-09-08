#include "../utils/hermite_coefficients"
#include "../utils/cubic_roots"

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
    vec2 t = vec2(prev_trace.depth, trace.depth);
    vec2 f = vec2(prev_trace.value, trace.value);
    vec2 f_prime = vec2(dot(prev_trace.gradient, ray.direction), dot(trace.gradient, ray.direction));

    // Compute cubic hermite coefficients
    vec4 coeff = hermite_coefficients(vec2(0.0, 1.0), f, f_prime); // for some reason the hermite_coefficients(t, f, f_prime); does not produce correct results
    coeff.x -= u_raycast.threshold;

    // Solve the equation H(t) = threshold for t in [0, 1]
    vec3 t_roots = cubic_roots(coeff);
    t_roots = mix(vec3(t.x), vec3(t.y), t_roots);

    // Filter the roots outside of interval
    vec3 roots_filter = step(vec3(t.x), t_roots) * step(t_roots, vec3(t.y));
    t_roots = (t_roots - t.y) * roots_filter + t.y;
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
