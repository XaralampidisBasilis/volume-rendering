#include "./modules/start_trace"
#include "./modules/compute_marching_bvh/start_occumap"

while(trace.step_count < ray.max_step_count) 
{
    #include "./modules/compute_marching_bvh/sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./modules/update_trace" 
    }
    else
    {
        #include "./modules/compute_marching_bvh/skip_trace"
    }

    if (!trace.update) break;
}   

if (occumap.block_occupied)
{
    #include "./modules/compute_marching_bvh/regress_trace"

    while(trace.step_count < ray.max_step_count) 
    {
        #include "./modules/update_trace" 
        
        if (!trace.update) break;
    }  
}

#include "./modules/end_trace" 


