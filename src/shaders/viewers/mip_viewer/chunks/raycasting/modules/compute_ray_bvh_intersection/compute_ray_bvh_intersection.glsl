
// from ray start skip blocks untill you find an occupied block at the lowest lod
while (ray.skip_count < ray.max_skip_count) 
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

    if (ray.start_distance > ray.end_distance) break;
}

// when you find and occupied block take a backstep 
if (occumap.block_occupied)  
{
    #include "./regress_ray_start"
}

// from ray end skip blocks untill you find an occupied block at the lowest lod
while (ray.skip_count < ray.max_skip_count) 
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

    if (ray.start_distance > ray.end_distance) break;
}

// when you find and occupied block take a frontstep 
if (occumap.block_occupied)  
{
    #include "./regress_ray_end"
}

// discard rays that did not find any occupied block
if (ray.start_distance > ray.end_distance)
{
    #include "../discard_ray"
}
