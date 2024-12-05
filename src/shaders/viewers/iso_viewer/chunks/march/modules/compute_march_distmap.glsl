
#include "./start_trace"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./compute_march_distmap/update_block
    
    if (block.occupied) 
    {
        #include "./update_trace" 
    }  
    else
    {
        #include "./compute_march_distmap/update_block_trace" 
    }

    if (!trace.update) break;
}

#include "./end_trace" 


