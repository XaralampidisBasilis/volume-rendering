
// initialize raymarch
#include "./modules/start_ray"
// #include "./modules/start_trace"

// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count; ) 
{
    #include "./modules/sample_volume"
    #include "./modules/update_trace"
}   

if (!ray.intersected)
{
    #include "./modules/end_trace"
}