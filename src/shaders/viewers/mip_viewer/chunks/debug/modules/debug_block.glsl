#include "./debug_block/debug_block_min_value"              
#include "./debug_block/debug_block_max_value"              
#include "./debug_block/debug_block_occupied"           
#include "./debug_block/debug_block_coords"             
#include "./debug_block/debug_block_skip_count"         
           
switch (u_debugging.option - debug.block_slot)
{
    case 1: fragColor = debug.block_min_value;  break;
    case 2: fragColor = debug.block_max_value;  break;
    case 3: fragColor = debug.block_occupied;   break;
    case 4: fragColor = debug.block_coords;     break;
    case 5: fragColor = debug.block_skip_count; break;
}

  