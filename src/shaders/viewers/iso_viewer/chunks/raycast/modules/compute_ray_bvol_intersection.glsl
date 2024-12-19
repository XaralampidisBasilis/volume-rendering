
// Compute ray entry with bounding volume
for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/update_ray_start_block"
    
    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection/update_ray_start"
    
    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}

if (block.occupied)
{
    #include "./compute_ray_bvol_intersection/refine_ray_start"
}


// Compute ray exit with bounding volume
for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/update_ray_end_block"

    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection/update_ray_end"
    
    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}

if (block.occupied)
{
    #include "./compute_ray_bvol_intersection/refine_ray_end"
}

// Discard ray if no intersection with bounding volume
if (ray.start_distance > ray.end_distance)
{
    #include "./discard_ray"
}
else 
{
    ray.span_distance = ray.end_distance - ray.start_distance;
}


