
// initialize raymarch
#include "./modules/start_occumap"
#include "./modules/start_ray"

float resample_distance = 0.0;

for (trace.step_count = 0; trace.step_count < ray.max_step_count; ) 
{
    #include "./modules/sample_occumaps"

    if (trace.block_occupied) 
    {
        #include "./modules/sample_volume"
        #include "./modules/update_trace"
    }
    else
    {
        #include "./modules/update_block"
    }
}   

