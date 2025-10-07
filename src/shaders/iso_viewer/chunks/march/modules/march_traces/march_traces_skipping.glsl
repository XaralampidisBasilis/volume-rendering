
#include "../march_blocks/start_block"

trace.spacing = ray.spacing / 5.0;
#include "./start_trace"

for (int k = 0; k < MAX_GROUPS; k++) 
{
    for (int j = 0; j < MAX_BLOCKS_PER_GROUP; j++) 
    {
        #include "../march_blocks/update_block"
        if (block.occupied || block.terminated) break;
    }

    if (!(block.occupied || block.terminated)) continue;
    #include "./start_trace"

    for (int i = 0; i < MAX_TRACES_PER_BLOCK; i++) 
    {
        #include "./update_trace"
        #include "./intersected_trace"
        if (trace.intersected || trace.terminated || trace.distance > block.exit_distance) break;
    }   

    if (trace.intersected || trace.terminated) break; 

    #if STATS_ENABLED == 1
    stats.num_groups += 1;
    #endif
}

#include "./end_trace"
