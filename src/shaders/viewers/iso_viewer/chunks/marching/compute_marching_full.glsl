#include "./modules/setup_trace"

for (trace.step_count = 0; 
     trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; ) 
{
    #include "./modules/update_volume_sample"
    if (trace.sample_value > u_raymarch.sample_threshold) break;
        
    #include "./modules/update_trace_position"
}   

#include "./modules/finalize_marching"