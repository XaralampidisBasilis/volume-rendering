
#include "../march_blocks/start_block"
#include "./start_cell"

for (int k = 0; k < MAX_GROUPS; k++) 
{
    for (int j = 0; j < MAX_BLOCKS_PER_GROUP; j++) 
    {
        #include "../march_blocks/update_block"
        if (block.occupied || block.terminated) break;
    }

    if (!(block.occupied || block.terminated)) continue;
    #include "./start_cell"

    for (int i = 0; i < MAX_CELLS_PER_BLOCK; i++) 
    {
        #include "./update_cell"
        #include "./intersected_cell"
        if (cell.intersected || cell.terminated || cell.exit_distance > block.exit_distance) break; 
    }   

    if (cell.intersected || cell.terminated) break;

    #if STATS_ENABLED == 1
    stats.num_groups += 1;
    #endif
}

#include "./end_cell"
