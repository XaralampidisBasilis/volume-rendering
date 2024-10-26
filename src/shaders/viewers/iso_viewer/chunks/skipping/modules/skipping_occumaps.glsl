
int occumap_min_lod = clamp(occumaps.min_lod, 0, occumaps.max_lod);

for (trace.skip_count = 0; trace.skip_count < ray.max_skip_count; trace.skip_count++) 
{
    #include "./update_block"

    if (trace.block_occupied)  
    {
        if (occumap.lod == occumap_min_lod) 
        {
            #include "./refine_block"
            break;
        }
        #include "./update_occumap"
        continue;
    }

    #include "./skip_block"

    if (trace.distance > ray.end_distance) break;
}
