
for (ray.skip_count = 0; 
     ray.skip_count < u_raymarch.max_skip_count && ray.start_distance < ray.end_distance; ) 
{
    #include "./sample_occumap"

    if (occumap.block_occupied)  
    {
        if (occumap.lod == u_raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./skip_block"
    }
}

if (ray.skip_count > 0)
{
    if (occumap.block_occupied)  
    {
        #include "./backstep_ray"
    }
    
    if (ray.start_distance > ray.end_distance)
    {
        #include "../end_ray"
    }
}
