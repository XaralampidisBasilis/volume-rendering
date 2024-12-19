#include "./modules/start_march"

for (int count = 0; count < MAX_TRACE_STEP_COUNT; count++, trace.step_count++) 
{
    #include "./modules/update_voxel" 
    #include "./modules/update_trace" 

    if (trace.saturated || trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

#include "./modules/end_march"