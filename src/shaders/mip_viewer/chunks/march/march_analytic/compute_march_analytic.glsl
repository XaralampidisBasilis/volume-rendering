
#include "./modules/start_march"

for (int count = 0; count < MAX_CELL_COUNT; count++) 
{
    #include "./modules/update_cell"

    if (trace.intersected)
    {
        break;
    }

    #include "./modules/update_trace"
    
    if (trace.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"