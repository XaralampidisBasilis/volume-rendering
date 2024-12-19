
#include "./modules/start_march"

for (int count = 0; count < MAX_TRACE_STEP_COUNT; count++, trace.step_count++) 
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