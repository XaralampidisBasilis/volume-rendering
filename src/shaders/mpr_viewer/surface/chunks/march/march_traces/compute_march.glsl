
// start march at ray start
#include "./modules/start_march"

for (int count = 0; count < MAX_TRACES; count++) 
{
    #include "./modules/update_trace"

    if (trace.intersected || trace.terminated) 
    {
        break;
    }
}   

// compute gradient at trace
#include "./modules/compute_gradient"
