#include "./modules/setup_trace"

for (trace.step_count = 0; 
     trace.step_count < RAY_MAX_STEP_COUNT && trace.distance < ray.end_distance;
     trace.step_count++) 
{
    #include "./modules/update_occumap_sample"

    if (occumap.block_occupied) 
    {
        #include "./modules/update_volume_sample"
        if (trace.sample_value > u_raymarch.sample_threshold) break;

        #include "./modules/update_trace_position"
    }
    else
    {
        #include "./modules/update_block_position"
    }
}   

if (trace.skip_count > 1)
{
    #include "./modules/regress_trace"

    for (trace.step_count; 
         trace.step_count < RAY_MAX_STEP_COUNT && trace.distance < ray.end_distance; 
         trace.step_count++) 
    {
        #include "./modules/update_volume_sample"
        if (trace.sample_value > u_raymarch.sample_threshold) break;
            
        #include "./modules/update_trace_position"
    }   
}

#include "./finalize_marching"


