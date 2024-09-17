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

// take a backstep to do a refined traverse
parameters_trace final_trace;
copy_trace(final_trace, trace);
copy_trace(trace, prev_trace);

// calculate the refined substep
float sub_spacing = trace.spacing / 6.0;  

// perform additional sampling steps to refine the hit point 
for (int i = 0; i < 5; i++, trace.steps++) 
{
    // move position forward by substep and sample the volume
    trace.position += sub_spacing * ray.direction;  
    trace.texel = trace.position * u_volume.inv_size;
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // if the sampled value exceeds the threshold, return early
    if (trace.error > 0.0) 
    {
        // extract gradient and distance
        vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
        trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
        trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
        trace.gradient = - trace.normal * trace.gradient_norm;
        trace.derivative = dot(trace.gradient, ray.direction);
        trace.distance = dot(trace.position - ray.origin, ray.direction);
        break;
    }
}
trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;

// if there was not any refinement copy the final trace
if (abs(trace.error) > abs(final_trace.error)) {
    copy_trace(trace, final_trace);
}


