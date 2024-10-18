
// Precompute invariant values outside the loop to avoid redundant work
float raycast_threshold = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold;
vec3 inv_volume_size = u_volume.inv_size;
vec3 inv_volume_spacing = u_volume.inv_spacing;
float inv_gradient_max_norm = 1.0 / u_gradient.max_norm;

ray.intersected = false;    

// Raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps && trace.distance < ray.max_distance; trace.steps++) 
{
    // Extract intensity and gradient from volume data in a single texture lookup
    vec4 volume_data = texture(u_sampler.volume, trace.texel);
    trace.value = volume_data.r;
    trace.error = trace.value - raycast_threshold;

    // Compute the gradient and its norm in a single step
    trace.gradient = mix(u_gradient.min, u_gradient.max, volume_data.gba);
    float gradient_norm = length(trace.gradient) * inv_gradient_max_norm;

    // Compute normalized gradient for further calculations
    trace.normal = -normalize(trace.gradient);
    
    // Include derivative calculations
    #include "../../derivatives/compute_derivatives"

    // If intensity exceeds threshold and gradient is strong enough, register an intersection
    if (trace.error > 0.0 && gradient_norm > gradient_threshold && trace.steps > 0) 
    {   
        ray.intersected = true;         
        break;
    }

    // Save the previous trace state
    #include "../../parameters/save_prev_trace"
    
    // Precompute stepping for the first iteration
    if (trace.steps == 0) {
        trace.stepping = u_raycast.min_stepping;
    } else {
        // Compute stepping normally for subsequent iterations
        #include "../../stepping/compute_stepping"
    }

    // Update ray position for the next step
    trace.spacing = trace.stepping * ray.spacing;
    trace.distance += trace.spacing;
    trace.position += ray.direction * trace.spacing;
    trace.texel = trace.position * inv_volume_size;
}   

// Compute the final depth and coordinates
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
prev_trace.depth = prev_trace.distance - ray.min_distance;
prev_trace.coords = floor(prev_trace.position * inv_volume_spacing);
