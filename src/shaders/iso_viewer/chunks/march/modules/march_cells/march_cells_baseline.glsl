
#include "./start_cell"

for (int i = 0; i < MAX_CELLS; i++) 
{
    #include "./update_cell"
    #include "./intersected_cell"

    if (cell.intersected || cell.terminated) break;
}

#include "./end_cell"
