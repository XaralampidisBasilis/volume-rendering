
#include "./modules/compute_low_bound"

// start march at ray start
#include "./modules/start_march"

for (int batch = 0; batch < u_rendering.max_count; batch++) 
{
    // Skip empty space using the precomputed chebyshev distance map 
    #include "./modules/start_block"

    for (int count = 0; count < u_rendering.max_block_count; count++) 
    {
        #include "./modules/update_block"

        if (block.occupied || block.terminated) 
        {
            break;
        }  
    }

    // March analytically the volume cells inside an occupied block
    #include "./modules/start_cell"

    for (int count = 0; count < u_rendering.max_cell_count; count++) 
    {
        #include "./modules/update_cell"

        if (cell.terminated) 
        {
            break;
        }
    }   

    // Termination condition
    cell.terminated = cell.exit_distance > ray.end_distance;

    if (cell.terminated) 
    {
        break;
    }
}   

// terminate march, compute intersection and gradient
#include "./modules/end_march"
