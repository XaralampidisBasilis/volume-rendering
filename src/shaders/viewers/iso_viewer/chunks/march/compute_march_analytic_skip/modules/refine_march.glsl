
#include "./refine_march/start_march"

for (int count = trace.step_count; count < MAX_TRACE_STEP_COUNT; count++, trace.step_count++) 
{
    #include "./refine_march/update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./refine_march/update_march"
    
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   