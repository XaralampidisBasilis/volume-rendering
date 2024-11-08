#include "./modules/start_trace"

while (trace.step_count < u_raymarch.max_step_count) 
{
    #include "./modules/update_trace" 
    if (!trace.update) break;
}   

#include "./modules/end_trace"