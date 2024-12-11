#include "./start_march"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./update_voxel" 
    #include "./update_trace" 

    if (trace.saturated || trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

#include "./end_march"