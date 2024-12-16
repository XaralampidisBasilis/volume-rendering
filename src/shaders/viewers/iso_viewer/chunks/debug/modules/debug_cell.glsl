
#include "./debug_cell/debug_cell_coords" 
#include "./debug_cell/debug_cell_step_coords" 
#include "./debug_cell/debug_cell_max_position" 
#include "./debug_cell/debug_cell_min_position" 
#include "./debug_cell/debug_cell_entry_distance" 
#include "./debug_cell/debug_cell_exit_distance"
#include "./debug_cell/debug_cell_distances" 
#include "./debug_cell/debug_cell_values"
#include "./debug_cell/debug_cell_coeffs"

switch (u_debugging.option - debug.cell_slot)
{ 
    case 1: fragColor = debug.cell_coords;         break; 
    case 2: fragColor = debug.cell_step_coords;    break; 
    case 3: fragColor = debug.cell_max_position;   break; 
    case 4: fragColor = debug.cell_min_position;   break; 
    case 5: fragColor = debug.cell_entry_distance; break; 
    case 6: fragColor = debug.cell_exit_distance;  break; 
    case 7: fragColor = debug.cell_distances;      break; 
    case 8: fragColor = debug.cell_values;         break; 
    case 9: fragColor = debug.cell_coeffs;         break; 
}

