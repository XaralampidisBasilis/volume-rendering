#include "./modules/setup_trace"

#if TRACE_BVH_MARCHING_ENABLED == 1
#include "./modules/compute_trace_bvh_marching"
#endif

for (trace.step_count; 
     trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; 
     trace.step_count++) 
{
    #include "./modules/sample_volume"
    if (trace.sample_value > u_raymarch.sample_threshold) break;
        
    #include "./modules/update_trace"
}   

#include "./modules/compute_trace_final_marching"