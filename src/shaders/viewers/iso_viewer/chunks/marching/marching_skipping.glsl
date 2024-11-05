

for (trace.step_count = 0; trace.step_count < ray.max_step_count;) 
{
    #include "./modules/sample_occumaps"

    if (trace.block_occupied) 
    {
        #include "./modules/sample_volume"
        if (ray.intersected) break;

        #include "./modules/update_trace"
    }
    else
    {
        #include "./modules/update_block"
    }

    if (trace.distance > ray.end_distance) break;
}   

#include "./modules/refine_block"

for (; trace.step_count < ray.max_step_count;) 
{
    #include "./modules/sample_volume"
    if (ray.intersected) break;

    #include "./modules/update_trace"
    if (trace.distance > ray.end_distance) break;
}   
