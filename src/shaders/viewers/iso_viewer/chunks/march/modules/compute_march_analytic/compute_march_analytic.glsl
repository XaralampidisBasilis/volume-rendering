
#include "./start_march"

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
{
    #include "./update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./update_march"
    
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

if (trace.intersected)
{
    #include "./compute_intersection"
}

#include "../end_march"