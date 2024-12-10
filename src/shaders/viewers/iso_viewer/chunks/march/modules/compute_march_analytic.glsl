#include "./start_march"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./compute_march_analytic/update_block
    
    if (block.occupied) 
    {
        #include "./update_voxel" 

        if (trace.intersected)
        {
            break;
        }

        #include "./update_trace" 
    }  
    else
    {
        #include "./compute_march_analytic/skip_block" 
    }

    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

if (block.occupied)
{
    #include "./compute_march_analytic/refine_trace"
}

#include "./end_march"
