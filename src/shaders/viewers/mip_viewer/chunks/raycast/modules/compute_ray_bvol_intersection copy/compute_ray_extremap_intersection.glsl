
// compute the block extrema across the ray
for (trace.distance = ray.start_distance; trace.distance < ray.end_distance; ) 
{
    #include "./sample_extremap"
    #include "./update_block_extrema"
    #include "./update_block_forward"
}

// compute the ray start based on extrema
for (trace.distance = ray.start_distance; trace.distance < ray.end_distance; ) 
{
    #include "./sample_extremap"

    if (trace.block_occupied)  
    {
        #include "./update_ray_start"
        break;
    }
    else
    {
        #include "./update_block_forward"
    }
}

// compute the ray end based on extrema
for (trace.distance = ray.end_distance; ray.start_distance < trace.distance; ) 
{
    #include "./sample_extremap"

    if (trace.block_occupied)  
    {
        #include "./update_ray_end"
        break;
    }
    else
    {
        #include "./update_block_backward"
    }
}

// clear trace
trace = set_trace();