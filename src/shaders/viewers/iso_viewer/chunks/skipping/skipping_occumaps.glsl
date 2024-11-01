
#include "./modules/start_occumap"

for (trace.skip_count = 0; trace.skip_count < raymarch.max_skip_count; /*trace.skip_count++*/) 
{
    #include "./modules/sample_occumaps"

    if (trace.block_occupied)  
    {
        #include "./modules/update_occumap"
    }
    else
    {
        #include "./modules/update_block"
    }
}

if (trace.block_occupied)  
{
    #include "./modules/refine_block"
}

#include "./modules/update_ray"

