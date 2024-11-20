#include "../start_trace"

for (trace.distance = ray.start_distance; trace.distance < ray.end_distance; ) 
{
    #include "./sample_extremap"

    if (trace.block_occupied) 
    {
        #include "../update_trace" 
    }
    else
    {
        #include "./update_block"
    }
}   

#include "../end_trace" 


