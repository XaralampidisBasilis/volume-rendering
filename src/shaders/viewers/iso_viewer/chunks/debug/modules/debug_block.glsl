#include "./debug_block/debug.block_value"       
#include "./debug_block/debug.block_occupied"    
#include "./debug_block/debug.block_coords"      
#include "./debug_block/debug.block_step_coords" 
#include "./debug_block/debug.block_min_position"
#include "./debug_block/debug.block_max_position"
#include "./debug_block/debug.block_skip_count"        
           
switch (u_debugging.option - debug.block_slot)
{
    case 1: fragColor = debug.block_value;        break;
    case 2: fragColor = debug.block_occupied;     break;
    case 3: fragColor = debug.block_coords;       break;
    case 4: fragColor = debug.block_step_coords;  break;
    case 5: fragColor = debug.block_min_position; break;
    case 6: fragColor = debug.block_max_position; break;
    case 7: fragColor = debug.block_skip_count;   break;
}

  