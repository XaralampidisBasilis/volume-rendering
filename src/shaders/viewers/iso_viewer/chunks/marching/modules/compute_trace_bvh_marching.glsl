
for (trace.step_count; 
     trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; ) 
{
    #include "./sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./sample_volume"
        if (trace.sample_value > u_raymarch.sample_threshold) break;

        #include "./update_trace"
        trace.step_count++;
    }
    else
    {
        #include "./update_block"
        trace.skip_count++;
    }
}   

if (occumap.block_occupied) 
{
    #include "./regress_trace"
}

