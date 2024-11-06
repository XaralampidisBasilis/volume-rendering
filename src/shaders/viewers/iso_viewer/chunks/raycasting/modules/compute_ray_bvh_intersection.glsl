
ivec3 block_coords; bool block_occupied;

for (int n; n < raymarch.max_skip_count && ray.start_distance < ray.end_distance; n++) 
{
    #include "./sample_occumap"

    if (block_occupied)  
    {
        if (occumap.lod == raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./update_block"
    }
}

if (block_occupied)  
{
   #include "./refine_block"
}
