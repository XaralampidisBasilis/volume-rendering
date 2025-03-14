
#include "./modules/start_march"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_block"

    if (block.intersected || block.terminated) 
    {
        break;
    }

    #include "./modules/update_voxels"
}   

#include "./modules/end_march"
