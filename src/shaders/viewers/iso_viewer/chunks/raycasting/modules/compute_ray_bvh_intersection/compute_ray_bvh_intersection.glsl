
for (ray.skip_count = 0; 
     ray.skip_count < u_raymarch.max_skip_count && ray.start_distance < ray.end_distance; ) 
{
    #include "./update_occumap_sample"

    if (occumap.block_occupied)  
    {
        if (occumap.lod == u_raymarch.min_skip_lod) break;

        #include "./update_occumap"
    }
    else
    {
        #include "./update_block_position"
    }
}

if (ray.skip_count > 0)
{
    if (occumap.block_occupied)  
    {
        #include "./regress_ray_position"
    }
    
    if (ray.start_distance > ray.end_distance)
    {
        #include "../terminate_ray_position"
    }
}
