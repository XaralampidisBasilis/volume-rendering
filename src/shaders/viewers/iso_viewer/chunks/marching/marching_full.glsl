
// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; trace.step_count++) 
{
    #include "./modules/sample_volume"
    if (trace.sample_value > raymarch.sample_threshold) break;
        
    #include "./modules/update_trace"
}   

#include "./modules/compute_trace_states"

if (trace.intersected) 
{
    #if RAY_REFINEMENT_ENABLED == 1
    #include "./modules/compute_trace_position_refinement"
    #endif

    #if RAY_GRADIENTS_ENABLED == 1
    #include "./modules/compute_trace_gradient_refinement"
    #endif
}

if (trace.suspended)
{
    #if RAY_GRADIENTS_ENABLED == 1
    #include "./modules/compute_trace_gradient_refinement"
    #endif
}

if (trace.terminated)
{
    #include "./modules/terminate_trace"

    #if RAY_DISCARDING_DISABLED == 0
    discard;  
    #endif
}
