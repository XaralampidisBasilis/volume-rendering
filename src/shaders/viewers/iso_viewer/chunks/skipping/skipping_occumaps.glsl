
#include "./modules/start_occumap"

for (trace.skip_count = 0; trace.skip_count < raymarch.max_skip_count; trace.skip_count++) 
{
    #include "./modules/sample_occumap"

    if (trace.block_occupied)  
    {
        if (occumap.lod == raymarch.min_skip_lod) 
        {
            #include "./modules/refine_block"
            break;
        }
        #include "./modules/update_occumap"
        continue;
    }

    #include "./modules/update_block"

    if (trace.distance > ray.end_distance) break;
}
