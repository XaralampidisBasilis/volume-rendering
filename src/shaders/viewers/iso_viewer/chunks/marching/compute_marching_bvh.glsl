#include "./modules/start_trace"

while(trace.step_count < u_raymarch.max_step_count) 
{
    #include "./modules/sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./modules/update_trace" 
        if (!trace.update) break;
    }
    else
    {
        #include "./modules/skip_block"
        if (!trace.update) break;
    }
}   

if (trace.skip_count > 1)
{
    #include "./modules/backstep_trace"

    while(trace.step_count < u_raymarch.max_step_count) 
    {
        #include "./modules/update_trace" 
        if (!trace.update) break;
    }   
}

#include "./modules/end_trace" 


