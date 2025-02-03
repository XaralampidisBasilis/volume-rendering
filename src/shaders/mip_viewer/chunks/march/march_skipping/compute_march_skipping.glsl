
// start march at ray start
#include "./modules/start_march"

for (int batch = 0; batch < MAX_BATCH_COUNT; batch++) 
{
    // Skip empty space using the precomputed chebyshev distance map 
    #include "./modules/start_block"

    for (int count = 0; count < MAX_BLOCK_SUB_COUNT; count++) 
    {
        // update block based on current trace
        #include "./modules/update_block"

        if (block.occupied) 
        {
            break;
        }  
        
        // update trace to skip the current block
        #include "./modules/skip_block"

        if (trace.terminated) 
        {
            break;
        } 
    }

    // March analytically the volume cells inside an occupied block
    #include "./modules/start_cell"

    for (int count = 0; count < MAX_CELL_SUB_COUNT; count++) 
    {
        // update current cell, take samples, and compute if there is intersection
        #include "./modules/update_cell"

        if (cell.intersected || cell.terminated) 
        {
            break;
        }
    }   

    // Update the trace and check termination conditions
    #include "./modules/update_trace"

    if (trace.intersected || trace.terminated) 
    {
        break;
    }
}   

trace.exhausted = (trace.intersected || trace.terminated) ? false : true;
// If batch marching is exhausted continue linearly?

// terminate march, compute intersection and gradient
#include "./modules/end_march"
