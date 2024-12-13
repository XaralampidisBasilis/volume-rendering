
#include "./start_march"

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
{
    if (trace.intersected)
    {
        break;
    }

    #include "./update_trace"

    if (trace.terminated || trace.exhausted) 
    {
        break;
    }

    #include "./update_cell"

}   

if (trace.intersected)
{
    #include "./refine_intersection"
}


#include "../end_march"