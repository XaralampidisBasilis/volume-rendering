
// start march at ray start
#include "./modules/start_march"

for (int count = 0; count < MAX_VOXELS; count++) 
{
    #include "./modules/update_voxel"

    if (voxel.intersected || voxel.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
