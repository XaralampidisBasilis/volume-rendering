#include "./modules/start_trace"
#include "./modules/marching_bvh/start_occumap"

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
}   

if (occumap.block_occupied)
{
    #include "./modules/marching_bvh/refine_trace"
}

while(trace.update) 
{
    #include "./modules/update_trace" 
}  

#include "./modules/end_trace" 


