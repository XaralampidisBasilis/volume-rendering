
// initialize raymarch
#include "./modules/start_occumap"
#include "./modules/start_ray"

float resample_distance = 0.0;

for (trace.step_count = 0; trace.step_count < ray.max_step_count && trace.skip_count < raymarch.max_skip_count; ) 
{
    if(trace.distance > resample_distance)
    {
        #include "./modules/sample_occumaps"

        if (trace.block_occupied) 
        {
            #include "./modules/regress_block"
        }
        else
        {
            #include "./modules/update_block"
            continue;
        }
    }

    #include "./modules/sample_volume"
    #include "./modules/update_trace"
}   
