#include "./modules/setup_trace"

#if TRACE_BVH_MARCHING_ENABLED == 1
#include "./modules/compute_trace_bvh_marching"
#endif

for (; trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; ) 
{
    #include "./modules/update_volume_sample"
    if (trace.sample_value > u_raymarch.sample_threshold) break;
        
    #include "./modules/update_trace_position"
    trace.step_count++;
}   

#include "./modules/compute_trace_finalize_marching"