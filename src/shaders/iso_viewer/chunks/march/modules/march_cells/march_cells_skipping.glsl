
#include "../march_blocks/start_block"

for (int k = 0; k < MAX_GROUPS; k++) 
{
    for (int j = 0; j < MAX_BLOCKS_PER_GROUP; j++) 
    {
        #include "../march_blocks/update_block"

        if (block.occupied || block.terminated) break;

        // #if DEBUG_ENABLED == 1
        // if (j >= u_debug.max_blocks) break;
        // #endif
    }

    if (!(block.occupied || block.terminated)) continue;

    #include "./start_cell"

    for (int i = 0; i < MAX_CELLS_PER_BLOCK; i++) 
    {
        #include "./update_cell"
        #include "./intersected_cell"

        if (cell.intersected || cell.terminated || cell.exit_distance > block.exit_distance) break; 
 
        // #if DEBUG_ENABLED == 1
        // if (i >= u_debug.max_cells) break;
        // #endif
    }   

    if (cell.intersected || cell.terminated) break;

    // #if DEBUG_ENABLED == 1
    // if (k >= u_debug.max_groups)  break;
    // #endif

    #if STATS_ENABLED == 1
    stats.num_groups += 1;
    #endif
}

#include "./end_cell"
