
#include "./modules/start_block"

for (int n = 0; n < u_rendering.max_block_count; n++) 
{
    #include "./modules/update_block"

    if (block.terminated)
    {
        break;
    }

    #include "./modules/start_trace"

    for (int i = 0; i < MAX_TRACE_SUBCOUNT; i++) 
    {
        #include "./modules/update_trace"

        if (trace.distance >= block.exit_distance || mip.intensity >= block.max_intensity) 
        {
            break;
        } 
    }

    if (trace.distance > ray.end_distance)
    {
        break;
    }
}   


// terminate march, compute intersection and gradient
#include "./modules/end_march"
