#include "../start_trace"
max_trace.sample_value = ray.block_min_value;

for (trace.distance = ray.start_distance; trace.distance < ray.end_distance && trace.step_count < u_raymarch.max_step_count; ) 
{
    #include "./sample_extremap"

    if (trace.block_occupied) 
    {
        #include "../update_trace" 
        
        float error = abs(ray.block_max_value - max_trace.sample_value);
        if (error < u_debugger.variable1) break;
    }
    else
    {
        #include "./update_block"
    }
}   

#include "../end_trace" 


