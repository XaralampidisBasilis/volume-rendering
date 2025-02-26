
// start march at ray start
#include "./modules/start_march"

for (int count = 0; count < MAX_VOXELS; count++) 
{
    // update current cell, take samples, and compute if there is intersection
    #include "./modules/update_cell"

    // Update the trace and check termination conditions
    #include "./modules/update_trace"

    // termination condition
    if (trace.terminated) 
    {
        break;
    }
}   

// compute gradients at mip trace
#include "./modules/compute_gradients"
