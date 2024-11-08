#include "./modules/start_trace"

for (trace.step_count = 0; trace.update; ) 
{
    #include "./modules/sample_occumap"

    if (occumap.block_occupied) 
    {
        #include "./modules/update_trace" 
    }
    else
    {
        #include "./modules/skip_block"
    }
}   

if (trace.skip_count > 1)
{
    #include "./modules/backstep_trace"

    for (trace.step_count; trace.update; ) 
    {
        #include "./modules/update_trace" 
    }   

}

#include "./modules/end_trace" 


