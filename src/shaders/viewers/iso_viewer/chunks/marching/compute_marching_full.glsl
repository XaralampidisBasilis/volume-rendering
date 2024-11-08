#include "./modules/start_trace"

for (trace.step_count = 0; trace.update; ) 
{
    #include "./modules/update_trace" 
}   

#include "./modules/end_trace"