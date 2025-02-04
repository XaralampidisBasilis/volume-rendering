
// start march at ray start
#include "./modules/start_march"

for (int batch = 0; batch < u_rendering.max_count; batch++) 
{
    #include "./modules/update_block"

    for (int count = 0; count < u_rendering.max_block_count; count++) 
    {
        if (block.occupied) 
        {
            break;
        }  

        #include "./modules/update_block"
    }


    #include "./modules/start_cell"

    for (int count = 0; count < u_rendering.max_cell_count; count++) 
    {
        #include "./modules/update_cell"

        if (cell.terminated || cell.saturated) 
        {
            break;
        }
    }   

    trace.distance = block.exit_distance;
    trace.position = camera.position + ray.direction * trace.distance; 
    trace.terminated = trace.distance > ray.end_distance;

    if (trace.terminated) 
    {
        break;
    }
    
}   

#include "./modules/compute_gradients"
