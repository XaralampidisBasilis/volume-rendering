
#include "./modules/start_block"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_block"

    if (block.intersected || block.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
