
for (int skip_count; skip_count < raymarch.max_skip_count && ray.start_distance < ray.end_distance; skip_count++) 
{
    #include "./sample_occumap"

    if (occumap.block_occupied)  
    {
        if (occumap.lod == raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./update_block"
    }
}

if (occumap.block_occupied)  
{
    #include "./regress_ray"
}
else
{
    #include "./terminate_ray"
}
