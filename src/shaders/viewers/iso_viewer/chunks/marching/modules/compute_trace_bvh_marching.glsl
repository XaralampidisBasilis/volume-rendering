
for (; trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; ) 
{
    #include "./update_occumap_sample"

    if (occumap.block_occupied) 
    {
        #include "./update_volume_sample"
        if (trace.sample_value > u_raymarch.sample_threshold) break;

        #include "./update_trace_position"
        trace.step_count++;
    }
    else
    {
        #include "./update_block_position"
        trace.skip_count++;
    }
}   

if (occumap.block_occupied) 
{
    #include "./regress_trace_position"
}

