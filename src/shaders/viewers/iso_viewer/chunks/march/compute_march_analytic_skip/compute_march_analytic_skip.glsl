
#include "./modules/start_march"

for (int count = 0; count < u_rendering.max_step_count; count++, trace.step_count++) 
{
    #include "./modules/update_block

    if (block.occupied) 
    {
        #include "./modules/update_cell"

        if (trace.intersected)
        {
            break;
        }

        #include "./modules/update_march"
    }  
    else
    {
        #include "./modules/skip_block" 
    }

    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   

// if (block.occupied)
// {
//     #include "./modules/refine_trace"
// }

#include "./modules/end_march"

