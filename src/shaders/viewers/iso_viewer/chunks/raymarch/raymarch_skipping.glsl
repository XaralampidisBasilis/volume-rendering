
// precompute invariant values outside the loop to avoid redundant memory access
float raycast_threshold = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold * u_gradient.max_norm;
vec3 inv_volume_size = u_volume.inv_size;
vec3 inv_volume_spacing = u_volume.inv_spacing;
ivec3 occupancy_base_dimensions = u_occupancy.base_dimensions;
vec3 occupancy_base_spacing = u_occupancy.base_spacing;
int occupancy_max_skips = u_occupancy.max_skips;

// skip initial empty space
#include "./modules/compute_skipping"

// initialize raymarch
#include "./modules/initialize_trace"
ray.intersected = false;    

// raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps; trace.steps++) 
{
    #include "./modules/update_occumap_sample"
    
    if (block.occupied) {

        #include "./modules/update_trace_sample"

        ray.intersected = trace.error > 0.0 && length(trace.gradient) > gradient_threshold;
        if (ray.intersected) break;

        prev_trace = trace;
        #include "./modules/update_trace_position"

    } else {

        #include "./modules/update_occumap_block"
    }

    if (trace.distance > ray.max_distance) break;
}   

