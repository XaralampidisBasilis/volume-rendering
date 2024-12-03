
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
        #include "./compute_march_distmap/skip_block" 
    }

    if (!trace.update) break;
}

if (block.occupied && trace.step_count > 1)  
{
    #include "./compute_march_distmap/regress_trace"

    for (trace.step_count; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
    {
        #include "./update_trace" 
        if (!trace.update) break;
    }   
}

#include "./end_trace" 


