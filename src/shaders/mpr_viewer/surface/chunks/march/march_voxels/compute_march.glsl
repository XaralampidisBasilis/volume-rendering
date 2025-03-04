
// start march at ray start
#include "./modules/start_march"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_voxel"

    if (voxel.intersected || voxel.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
