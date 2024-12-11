
// Compute ray entry with bounding volume
for (block.skip_count = 0; block.skip_count < MAX_BLOCK_SKIP_COUNT; block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/block_ray_start
    
    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection/update_ray_start
    
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
for (block.skip_count; block.skip_count < MAX_BLOCK_SKIP_COUNT; block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/block_ray_end

    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection/update_ray_end
    
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


