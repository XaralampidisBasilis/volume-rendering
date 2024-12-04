
#include "./start_trace"

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count;) 
{
    #include "./compute_march_distmap/update_block
    
    if (block.occupied) 
    {
        #include "./update_trace" 
        trace.step_count++;
    }  
    else
    {
        #include "./compute_march_distmap/update_block_trace" 
        block.skip_count++;
    }

    if (!trace.update) break;
}

#include "./end_trace" 


