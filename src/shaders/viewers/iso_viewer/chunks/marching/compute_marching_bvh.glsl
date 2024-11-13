#include "./modules/start_trace"
#include "./modules/marching_bvh/start_occumap"
#include "./modules/update_condition" 

while(trace.update) 
{
    #include "./modules/marching_bvh/sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./modules/update_trace" 
    }
    else
    {
        #include "./modules/marching_bvh/skip_block"
    }

    #include "./modules/update_condition" 
}   

#include "./modules/marching_bvh/refine_trace"
#include "./modules/update_condition" 

while(trace.update) 
{
    #include "./modules/update_trace" 
    #include "./modules/update_condition" 
}  

#include "./modules/end_trace" 


