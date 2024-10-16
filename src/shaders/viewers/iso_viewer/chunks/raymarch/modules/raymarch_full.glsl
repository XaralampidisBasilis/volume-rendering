
ray.intersected = false;    

// Raymarch loop to traverse through the volume
for (
    trace.steps = 0; 
    trace.steps < ray.max_steps && trace.distance < ray.max_distance; 
    trace.steps++
) 
{
    // Extract intensity value from volume data
    vec4 volume_data = texture(u_sampler.volume, trace.texel);
    trace.value = volume_data.r;
    trace.error = trace.value - u_raycast.threshold;

    // Extract gradient from volume data
    trace.gradient = mix(u_gradient.min, u_gradient.max, volume_data.gba);
    trace.gradient_norm = length(trace.gradient);
    trace.normal = - normalize(trace.gradient);
    float gradient_norm = trace.gradient_norm / u_gradient.max_norm;
    
    #include "../../derivatives/compute_derivatives"

    // Check if the sampled intensity exceeds the threshold
    if (trace.error > 0.0 && gradient_norm > u_gradient.threshold && trace.steps > 0) 
    {   
        ray.intersected = true;         
        break;
    }

    // save prev trace
    #include "../../parameters/save_prev_trace"
    
    // compute stepping
    #include "../../stepping/compute_stepping"
    // #include "../../dithering/modules/dithering_dynamic"
    if (trace.steps < 1) 
    {
        trace.stepping = u_raycast.min_stepping;
    }

    // Update ray position for the next step
    trace.spacing = trace.stepping * ray.spacing;
    trace.distance += trace.spacing;
    trace.position += ray.direction * trace.spacing;
    trace.texel = trace.position * u_volume.inv_size;
}   

trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * u_volume.inv_spacing);
prev_trace.depth = prev_trace.distance - ray.min_distance;
prev_trace.coords = floor(prev_trace.position * u_volume.inv_spacing);