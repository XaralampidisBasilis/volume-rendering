
// Start trace
trace.distance = ray.start_distance;
trace.position = ray.start_position;

// Compute ray bounding values
for (int count = 0; count < 500; count++) 
{
    #include "./compute_ray_bvol_intersection/block_trace"
    #include "./compute_ray_bvol_intersection/update_trace"

    // update ray bounding values
    ray.min_value = max(ray.min_value, block.min_value);
    ray.max_value = max(ray.max_value, block.max_value);    
 
    if (trace.distance > ray.end_distance) 
    {
        break;
    }
}

// Compute ray start
for (int count = 0; count < 100; count++) 
{
    #include "./compute_ray_bvol_intersection/block_ray_start"

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

// Compute ray end
for (int count = 0; count < 100; count++) 
{
    #include "./compute_ray_bvol_intersection/block_ray_end"

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

// Compute span
ray.span_distance = ray.end_distance - ray.start_distance;
