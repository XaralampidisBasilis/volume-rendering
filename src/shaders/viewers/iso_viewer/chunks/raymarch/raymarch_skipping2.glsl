
// initialize raymarch
#include "./modules/start_occumap"
#include "./modules/start_ray"
#include "./modules/start_trace"

ivec3 block_coords = ivec3(-1);

// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count; trace.step_count++) 
{
    if (any(notEqual(trace.block_coords, block_coords))) 
    {
        #include "./modules/sample_occumap"

        if (trace.block_occupied) 
        {
            #include "./modules/refine_block"
        } 
        else 
        {
            #include "./modules/update_block"
        }
    }
   
    #include "./modules/update_ray"
}   

