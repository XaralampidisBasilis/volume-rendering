
#include "./compute_march_analytic/start_march"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./compute_march_analytic/update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./compute_march_analytic/update_march"
    
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

if (trace.intersected)
{
    #include "./compute_march_analytic/compute_intersection"
}

#include "./compute_march_analytic/end_march"