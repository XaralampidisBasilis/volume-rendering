
// Compute ray extrema values
#include "./compute_ray_bvol_intersection_2/set_trace_block"

for (int count = 0; count < MAX_BLOCK_SKIP_COUNT; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/update_trace_block"
    
    #include "./compute_ray_bvol_intersection_2/update_trace"

    if (trace.distance > ray.end_distance) 
    {
        break;
    }
}

// Compute ray start
#include "./compute_ray_bvol_intersection_2/set_ray_start_block"

for (int count = 0; count < MAX_BLOCK_SKIP_COUNT; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/update_ray_block"

    if (block.occupied)  
    {
        break;
    }
        
    #include "./compute_ray_bvol_intersection_2/update_ray_start"

    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}


// Compute ray end
#include "./compute_ray_bvol_intersection_2/set_ray_end_block"

for (int count = 0; count < MAX_BLOCK_SKIP_COUNT; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/update_ray_block"

    if (block.occupied)  
    {
        break;
    }
 
    #include "./compute_ray_bvol_intersection_2/update_ray_end"

    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}


// Finish
ray.range_value = ray.max_value - ray.min_value;
ray.span_distance = ray.end_distance - ray.start_distance;
