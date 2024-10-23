#include "./modules/start_occumap_lod"

for (block.skips = 0; block.skips < occumap.max_skips; block.skips++) 
{
    #include "./modules/update_block_sample"

    if (block.occupied) 
    {
        if (occumap.lod == u_occupancy.min_lod) 
        {
            #include "./modules/end_block_position"
            break;
        }
        #include "./modules/update_occumap_lod"
        continue;
    }
        
    #include "./modules/update_block_position"

    if (trace.distance > ray.max_distance) break;
}
