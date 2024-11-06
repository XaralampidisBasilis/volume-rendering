
for (int i; i < raymarch.max_skip_count && ray.start_distance < ray.end_distance; i++) 
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
    #include "./refine_ray"
}
else
{
    #include "./terminate_ray"
}
