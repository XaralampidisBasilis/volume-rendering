
#include "./modules/start_voxel"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_voxel"

    if (voxel.intersected || voxel.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
