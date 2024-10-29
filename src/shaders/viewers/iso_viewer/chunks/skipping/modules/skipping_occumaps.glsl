

int min_lod = clamp(occumaps.min_lod, 0, occumaps.max_lod);

for (trace.skip_count = 0; trace.skip_count < ray.max_skip_count; trace.skip_count++) 
{
    #include "./sample_occumap"

    if (trace.block_occupied)  
    {
        if (occumap.lod == min_lod) 
        {
            #include "./refine_block"
            break;
        }
        #include "./update_occumap"
        continue;
    }

    #include "./update_block"

    if (trace.distance > ray.end_distance) break;
}
