
#include "./start_occumap"

for (trace.skip_count = 0; trace.skip_count < ray.max_skip_count; trace.skip_count++) 
{
    #include "./sample_occumap"

    if (trace.block_occupied)  
    {
        if (occumap.lod == raymarch.min_skip_lod) 
        {
            #include "./refine_trace"
            break;
        }
        #include "./update_occumap"
        continue;
    }

    #include "./update_block"

    if (trace.distance > ray.end_distance) break;
}
