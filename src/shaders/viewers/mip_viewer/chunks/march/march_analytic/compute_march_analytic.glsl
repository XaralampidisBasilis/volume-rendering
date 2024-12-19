#include "./modules/start_march"

for (int count = 0; count < u_rendering.max_step_count; count++, trace.step_count++) 
{
    #include "./modules/update_cell" 

    #include "./modules/update_march" 

    if (trace.terminated || trace.exhausted || voxel.saturated) 
    {
        break;
    }
}   

