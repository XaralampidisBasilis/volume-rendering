
for (trace.step_count; 
     trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; 
     trace.step_count++) 
{
    #include "./sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./sample_volume"
        if (trace.sample_value > raymarch.sample_threshold) break;

        #include "./update_trace"
    }
    else
    {
        #include "./update_block"
    }
}   
