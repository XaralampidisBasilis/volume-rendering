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
void refinement_bisection
(
    in uniforms_volume u_volume, 
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient, 
    in uniforms_sampler u_sampler, 
    in parameters_ray ray,
    inout parameters_trace trace
)
{
    // Initialize the positions and values, reducing the use of arrays
    vec3 position0 = trace.position - ray.direction * trace.spacing;
    vec3 position1 = trace.position;
    float value0 = trace.value - texture(u_sampler.volume, position0 * u_volume.inv_size).r;
    float value1 = trace.value;

    // Perform sampling steps for refinement
    for (int i = 0; i < u_raycast.refinements; i++, trace.i_step++) 
    {
        // Compute interpolation factor
        float t = rampstep(value0, value1, u_raycast.threshold);

        // Interpolate position based on 't'
        trace.position = mix(position0, position1, t);
        trace.texel = trace.position * u_volume.inv_size;

        // Sample the intensity at the interpolated position
        trace.value = texture(u_sampler.volume, trace.texel).r;
        trace.error = trace.value - u_raycast.threshold;

        // Update position and value based on error
        float s = step(0.0, trace.error);
        position0 = mix(trace.position, position0, s);
        position1 = mix(position1, trace.position, s);
        value0 = mix(trace.value, value0, s);
        value1 = mix(value1, trace.value, s);
    }

    // Compute the gradient and additional properties
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.steepness = gradient_data.a * u_gradient.range_length + u_gradient.min_length;
    trace.gradient = trace.normal * trace.steepness;

    // Compute the depth
    trace.depth = dot(trace.position - ray.origin, ray.direction);
}
