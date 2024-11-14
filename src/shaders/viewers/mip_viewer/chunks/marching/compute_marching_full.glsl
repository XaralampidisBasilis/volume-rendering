#include "./modules/start_trace"

while (trace.step_count < ray.max_step_count) 
{
    #include "./modules/update_trace" 
    
    if (!trace.update) break;
}   

#include "./modules/end_trace"