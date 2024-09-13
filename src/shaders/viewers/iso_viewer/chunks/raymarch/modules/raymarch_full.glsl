
// take a backstep in order to compute initial prev_trace
ray.intersected = false;         
trace.distance -= ray.max_spacing;
trace.position = ray.origin + ray.direction * trace.distance;

// Raymarch loop to traverse through the volume
for (
    trace.steps = 0; 
    trace.steps < ray.max_steps && trace.distance < ray.max_distance; 
    trace.steps++
) 
{
    // Sample the intensity of the volume at the current ray position
    trace.texel = trace.position * u_volume.inv_size;
    trace.value = texture(u_sampler.volume, trace.texel).r;
    trace.error = trace.value - u_raycast.threshold;

    // Extract gradient and value from texture data
    vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
    trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
    trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
    trace.gradient = - trace.normal * trace.gradient_norm;
    trace.derivative = dot(trace.gradient, ray.direction);

    // Check if the sampled intensity exceeds the threshold
    if (trace.error > 0.0 && gradient_data.a > u_gradient.threshold && trace.steps > 0) 
    {   
        // Compute refinement
        ray.intersected = true;         
        break;
    }

    // save prev trace
    #include "../../parameters/save_prev_trace"

    // Update ray position for the next step
    #include "../../stepping/compute_stepping"
    trace.spacing = trace.stepping * ray.spacing;
    trace.distance += trace.spacing;
    trace.position += ray.direction * trace.spacing;
}   

