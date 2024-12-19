#include "./modules/start_march"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./modules/update_block" 

    if (block.occupied) 
    {
        #include "./modules/update_voxel" 
        #include "./modules/update_trace" 
    }
    else
    {
        #include "./modules/skip_block" 
    }

    if (trace.saturated || trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

#include "./modules/end_march"
