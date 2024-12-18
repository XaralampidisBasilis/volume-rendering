
#include "./modules/start_march"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./modules/update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./modules/update_march"
    
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

#include "./modules/end_march"