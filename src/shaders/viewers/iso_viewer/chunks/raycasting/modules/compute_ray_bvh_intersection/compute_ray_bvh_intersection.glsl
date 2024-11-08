
// find ray start
ray.skip_count = 0;

while (ray.start_distance < ray.end_distance && ray.skip_count < u_raymarch.max_skip_count) 
{
    #include "./sample_occumap_at_ray_start"

    if (occumap.block_occupied)  
    {
        if (occumap.lod == u_raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./update_ray_start"
    }
}

if (ray.skip_count > 0)
{
    if (occumap.block_occupied)  
    {
        #include "./refine_ray_start"
    }
    
    if (ray.start_distance > ray.end_distance)
    {
        #include "../discard_ray"
    }
}

// find ray end
ray.skip_count = 0;

while (ray.end_distance > ray.start_distance && ray.skip_count < u_raymarch.max_skip_count) 
{
    #include "./sample_occumap_at_ray_end"

    if (occumap.block_occupied)  
    {
        if (occumap.lod == u_raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./update_ray_end"
    }
}

if (ray.skip_count > 0)
{
    if (occumap.block_occupied)  
    {
        #include "./refine_ray_end"
    }
}

