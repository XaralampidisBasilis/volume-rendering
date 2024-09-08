#include "../utils/lagrange_coefficients"
#include "../utils/quadratic_roots"

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
    float t_linear = rampstep(prev_trace.value, trace.value, u_raycast.threshold);

    vec3 texel = mix(prev_trace.texel, trace.texel, t_linear);
    float depth = mix(prev_trace.depth, trace.depth, t_linear);
    float value = texture(u_sampler.volume, texel).r;

    // Define symbolic vectors
    vec3 t = vec3(prev_trace.depth, depth, trace.depth);
    vec3 f = vec3(prev_trace.value, value, trace.value);

    // Compute cubic hermite coefficients
    vec3 coeff = lagrange_coefficients(vec3(0.0, t_linear, 1.0), f); 
    coeff.x -= u_raycast.threshold;

    // Solve the equation H(t) = threshold for t in [0, 1]
    vec2 t_roots = quadratic_roots(coeff);
    t_roots = mix(vec2(t.x), vec2(t.z), t_roots);

    // Filter the roots outside of interval
    vec2 roots_filter = step(vec2(t.x), t_roots) * step(t_roots, vec2(t.z));
    t_roots = (t_roots - t.z) * roots_filter + t.z;
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
