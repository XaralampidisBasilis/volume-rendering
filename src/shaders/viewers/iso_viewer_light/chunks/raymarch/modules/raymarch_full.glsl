
// Precompute invariant values outside the loop to avoid redundant work
float raycast_threshold = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold * u_gradient.max_norm;
vec3 inv_volume_size = u_volume.inv_size;
vec3 inv_volume_spacing = u_volume.inv_spacing;

ray.intersected = false;    

// Raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps && trace.distance < ray.max_distance; trace.steps++) 
{
   
    #include "./update_sample"
    #include "../../derivatives/compute_derivatives"

    // If intensity exceeds threshold and gradient is strong enough, register an intersection
    if (trace.error > 0.0 && length(trace.gradient) > gradient_threshold && trace.steps > 0) 
    {   
        ray.intersected = true;         
        break;
    }

    // Save the previous trace state
    #include "../../parameters/save_prev_trace"
    #include "./update_step"
}   

// Compute the final depth and coordinates
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
prev_trace.depth = prev_trace.distance - ray.min_distance;
prev_trace.coords = floor(prev_trace.position * inv_volume_spacing);
