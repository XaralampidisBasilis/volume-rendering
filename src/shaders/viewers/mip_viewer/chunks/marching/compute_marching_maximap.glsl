#include "./modules/start_trace"

while(trace.step_count < ray.max_step_count) 
{
    #include "./modules/compute_marching_maximap/sample_maximap"

    if (trace.block_occupied) 
    {
        #include "./modules/update_trace" 
    }
    else
    {
        #include "./modules/compute_marching_maximap/update_block"
    }

    if (!trace.update) break;
}   

#include "./modules/end_trace" 


