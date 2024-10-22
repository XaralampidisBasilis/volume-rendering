
// precompute invariant values outside the loop to avoid redundant memory access
vec3  inv_volume_size    = u_volume.inv_size;
vec3  inv_volume_spacing = u_volume.inv_spacing;
float raycast_threshold  = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold * u_gradient.max_norm;

// initialize raymarch
#include "./modules/initialize_trace"

// raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps; trace.steps++) 
{
    #include "./modules/update_trace_sample"

    ray.intersected = trace.error > 0.0 && length(trace.gradient) > gradient_threshold;
    if (ray.intersected) break;

    prev_trace = trace;
    #include "./modules/update_trace_position"
    if (trace.distance > ray.max_distance) break;
}   

