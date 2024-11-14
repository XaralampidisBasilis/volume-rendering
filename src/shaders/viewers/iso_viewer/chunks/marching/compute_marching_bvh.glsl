#include "./modules/start_trace"
#include "./modules/compute_marching_bvh/start_occumap"

while(trace.update) 
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
}   

if (occumap.block_occupied)
{
    #include "./modules/compute_marching_bvh/regress_trace"

    while(trace.update) 
    {
        #include "./modules/update_trace" 
    }  
}

#include "./modules/end_trace" 


